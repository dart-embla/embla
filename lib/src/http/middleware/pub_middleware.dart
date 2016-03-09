import 'dart:async';
import 'dart:io';

import '../../../http.dart';
import 'forwarder_middleware.dart';
import 'static_files_middleware.dart';

class PubMiddleware extends Middleware {
  final bool developmentMode;
  final int servePort;
  final String buildDir;

  Middleware __static;
  Middleware __forward;

  Middleware get _static => __static
    ??= new StaticFilesMiddleware(fileSystemPath: '$buildDir/web', defaultDocument: 'index.html');
  Middleware get _forward => __forward
    ??= new ForwarderMiddleware(to: 'http://localhost:$servePort');

  PubMiddleware({
    bool developmentMode,
    this.servePort: 8080,
    this.buildDir: 'build'
  }) : developmentMode = developmentMode ?? Platform.environment['APP_ENV'] == 'development';

  @override Future<Response> handle(Request request) async {
    final response = developmentMode
      ? await _forward.handle(request)
      : await _static.handle(request);

    if (response.statusCode == 404) {
      abortNotFound(await response.readAsString());
    }

    return response;
  }
}
