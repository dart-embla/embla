import 'dart:async';
import '../middleware.dart';
import '../pipeline.dart';
import '../request_response.dart';

class ConditionalMiddleware extends Middleware {
  final Function condition;
  final PipelineFactory _pipeline;
  Pipeline __pipeline;

  Pipeline get pipeline => __pipeline ??= _pipeline();

  ConditionalMiddleware(this.condition, this._pipeline);

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
