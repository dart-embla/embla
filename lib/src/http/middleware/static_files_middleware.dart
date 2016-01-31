import 'dart:async';

import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf_static/shelf_static.dart' as shelf_static;

import '../middleware.dart';

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
    final Response response = await handler(request);
    if (response.statusCode == 404) {
      throw new HttpNotFoundException('No file found at ${fileSystemPath}/${request.url.path}');
    }
    return response;
  }
}
