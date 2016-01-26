import 'http.dart';
import 'dart:async';
import 'package:shelf_static/shelf_static.dart' as shelf_static;
import 'package:shelf/shelf.dart' as shelf;

class RemoveTrailingSlashMiddleware extends Middleware {
  @override Future<Response> handle(Request request) async {
    if (request.url.path.endsWith('/')) {
      final url = request.handlerPath + request.url.path;
      return redirectPermanently('/' + url.split('/').where((s) => s.isNotEmpty).join('/'));
    }
    return await super.handle(request);
  }
}

class LoggerMiddleware extends Middleware {
  @override Future<Response> handle(Request request) async {
    final beforeTime = new DateTime.now();
    duration() => beforeTime.difference(new DateTime.now());
    try {
      final response = await super.handle(request);
      _log(request, response.statusCode, duration());
      return response;
    } on NoResponseFromPipelineException {
      _log(request, 404, duration());
      rethrow;
    } on HttpException catch(e) {
      _log(request, e.statusCode, duration());
      rethrow;
    } catch(e) {
      _log(request, 500, duration());
      rethrow;
    }
  }

  void _log(Request request, int statusCode, Duration time) {
    final url = request.handlerPath + request.url.path;
    final statusColor = () {
      if (statusCode >= 200 && statusCode < 300) {
        return 'green';
      }
      if (statusCode >= 300 && statusCode < 400) {
        return 'magenta';
      }
      if (statusCode >= 400 && statusCode < 500) {
        return 'yellow';
      }
      if (statusCode >= 500 && statusCode < 600) {
        return 'red';
      }
      return 'black';
    }();

    final timeInMilliseconds = time.abs().inMicroseconds / 1000;
    final timeColor = () {
      if (timeInMilliseconds > 800) {
        return 'red';
      }
      if (timeInMilliseconds > 400) {
        return 'yellow';
      }
      return 'gray';
    }();

    print('<gray><italic>${new DateTime.now()}</italic></gray> '
        '<$statusColor>$statusCode</$statusColor> '
        '<blue>${request.method}</blue> '
        '$url '
        '<$timeColor><italic>$timeInMilliseconds ms</italic></$timeColor>');
  }
}

class StaticFilesMiddleware extends Middleware {
  final String fileSystemPath;
  final bool serveFilesOutsidePath;
  final String defaultDocument;
  final bool listDirectories;
  final shelf.Handler handler;

  StaticFilesMiddleware({
      String fileSystemPath: 'web',
      bool serveFilesOutsidePath: false,
      String defaultDocument,
      bool listDirectories: false
      })
      : fileSystemPath = fileSystemPath,
        serveFilesOutsidePath = serveFilesOutsidePath,
        defaultDocument = defaultDocument,
        listDirectories = listDirectories,
        handler = shelf_static.createStaticHandler(
            fileSystemPath,
            serveFilesOutsidePath: serveFilesOutsidePath,
            defaultDocument: defaultDocument,
            listDirectories: listDirectories
        );

  @override Future<Response> handle(Request request) async {
    return await handler(request);
  }
}
