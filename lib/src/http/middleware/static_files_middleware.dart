import 'dart:async';

import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf_static/shelf_static.dart' as shelf_static;

import '../middleware.dart';

class StaticFilesMiddleware extends Middleware {
  final String fileSystemPath;
  final bool serveFilesOutsidePath;
  final String defaultDocument;
  final bool listDirectories;
  shelf.Handler _handler;
  shelf.Handler get handler => _handler ??= shelf_static.createStaticHandler(
      fileSystemPath,
      serveFilesOutsidePath: serveFilesOutsidePath,
      defaultDocument: defaultDocument,
      listDirectories: listDirectories
  );

  StaticFilesMiddleware({
    this.fileSystemPath: 'web',
    this.serveFilesOutsidePath: false,
    this.defaultDocument,
    this.listDirectories: false
  });

  @override Future<Response> handle(Request request) async {
    final Response response = await handler(request);
    if (response.statusCode == 404) {
      throw new HttpNotFoundException('No file found at ${fileSystemPath}/${request.url.path}');
    }
    return response;
  }
}
