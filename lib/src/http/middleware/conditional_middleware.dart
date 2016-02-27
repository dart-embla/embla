import 'dart:async';
import '../middleware.dart';
import '../pipeline.dart';
import '../request_response.dart';

class ConditionalMiddleware extends Middleware {
  final Function condition;
  final Pipeline pipeline;

  ConditionalMiddleware(Function condition, PipelineFactory pipeline)
      : condition = condition,
        pipeline = pipeline();

  @override Future<Response> handle(Request request) async {
    try {
      if (await context.container.resolve(condition)) {
        return await pipeline(request);
      } else {
        return await super.handle(request);
      }
    } on NoResponseFromPipelineException {
      return await super.handle(request);
    }
  }
}
