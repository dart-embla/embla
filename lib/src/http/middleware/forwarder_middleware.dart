import 'dart:async';
import 'dart:io';

import '../middleware.dart' hide HttpException;

class ForwarderMiddleware extends Middleware {
  final String prefix;

  ForwarderMiddleware({String to})
    : prefix = to ?? 'http://localhost:8080';

  Uri _url(String path) {
    final url = prefix.replaceFirst(new RegExp(r'\/$'), '')
      + '/'
      + path.replaceFirst(new RegExp(r'^\/'), '');

    return Uri.parse(url);
  }

  Future<Response> handle(Request request) async {
    final url = _url(request.requestedUri.path);
    final httpClient = new HttpClient();

    try {
      final forwardRequest = await httpClient.openUrl(request.method, url);

      request.headers.forEach(forwardRequest.headers.add);

      await forwardRequest.addStream(request.read());

      final response = await forwardRequest.close();

      final responseHeaders = <String, String>{};

      response.headers.forEach((k, v) => responseHeaders[k] = v.join(';'));

      if (response.headers['content-encoding']?.indexOf('gzip') == 0) {
        responseHeaders.remove('content-encoding');
      }

      return new Response(
        response.statusCode,
        body: response,
        headers: responseHeaders
      );
    } on SocketException {
      abortBadGateway('Could not forward to $url');
    } on HttpException catch(e) {
      abortInternalServerError(e.message);
    } finally {
      httpClient.close();
    }
  }
}
