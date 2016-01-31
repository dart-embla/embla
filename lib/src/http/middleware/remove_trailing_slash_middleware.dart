import 'dart:async';

import '../middleware.dart';

class RemoveTrailingSlashMiddleware extends Middleware {
  @override Future<Response> handle(Request request) async {
    if (request.url.path.endsWith('/')) {
      final url = request.handlerPath + request.url.path;
      return redirectPermanently('/' + url.split('/').where((s) => s.isNotEmpty).join('/'));
    }
    return await super.handle(request);
  }
}
