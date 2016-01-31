import 'dart:async';
import '../middleware.dart';
import '../pipeline.dart';
import '../request_response.dart';

class ConditionalMiddleware extends Middleware {
  final Function condition;
  final Pipeline pipeline;

  ConditionalMiddleware(condition(Request request), PipelineFactory pipeline)
      : condition = condition,
        pipeline = pipeline();

  @override Future<Response> handle(Request request) async {
    try {
      if (await condition(request)) {
        return await pipeline(request);
      } else {
        return await super.handle(request);
      }
    } on NoResponseFromPipelineException {
      return await super.handle(request);
    }
  }
}
