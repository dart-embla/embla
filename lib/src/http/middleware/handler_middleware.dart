import 'dart:async';

import '../middleware.dart';
import '../context.dart';
import '../request_response.dart';

class HandlerMiddleware extends Middleware {
  final Function handler;

  HandlerMiddleware(this.handler);

  @override Future<Response> handle(Request request) async {
    final returnValue = await context.container.resolve(handler);
    if (returnValue is Response) return returnValue;
    return ok(returnValue);
  }
}
