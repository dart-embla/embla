import 'dart:async';
import 'dart:mirrors';

import 'package:shelf/shelf.dart' as shelf;

import '../util/nothing.dart';
import 'middleware.dart';
import 'middleware/conditional_middleware.dart';
import 'middleware/handler_middleware.dart';
import 'request_response.dart';
import 'context.dart';
import '../../container.dart';

PipelineFactory pipe(
    [middlewareA = nothing, middlewareB = nothing, middlewareC = nothing,
    middlewareD = nothing, middlewareE = nothing, middlewareF = nothing, middlewareG = nothing,
    middlewareH = nothing, middlewareI = nothing, middlewareJ = nothing, middlewareK = nothing,
    middlewareL = nothing, middlewareM = nothing, middlewareN = nothing, middlewareO = nothing,
    middlewareP = nothing, middlewareQ = nothing, middlewareR = nothing, middlewareS = nothing,
    middlewareT = nothing, middlewareU = nothing, middlewareV = nothing, middlewareW = nothing,
    middlewareX = nothing, middlewareY = nothing, middlewareZ = nothing]) {
  final Iterable middlewareTokens = [middlewareA, middlewareB,
  middlewareC, middlewareD, middlewareE, middlewareF, middlewareG, middlewareH,
  middlewareI, middlewareJ, middlewareK, middlewareL, middlewareM, middlewareN,
  middlewareO, middlewareP, middlewareQ, middlewareR, middlewareS, middlewareT,
  middlewareU, middlewareV, middlewareW, middlewareX, middlewareY, middlewareZ
  ].where((m) => m != nothing);
  return ([IoCContainer container]) => pipeActual(resolveMiddleware(middlewareTokens, container));
}

Pipeline pipeActual(Iterable<shelf.Middleware> middleware) {
  final shelf.Pipeline pipe = middleware.fold/*<shelf.Pipeline>*/(
      const shelf.Pipeline(),
      (shelf.Pipeline pipeline, shelf.Middleware middleware) {
    return pipeline.addMiddleware(middleware);
  });
  final shelf.Handler handler = pipe.addHandler((Request request) {
    throw new NoResponseFromPipelineException();
  });

  Future<Response> pipeline(Request request) async => handler(request);
  return pipeline;
}

Iterable<Middleware> resolveMiddleware(Iterable tokens, [IoCContainer container]) sync* {
  final ioc = container ?? context.container;
  for (final token in tokens) {
    if (token is shelf.Middleware) {
      yield token;
    } else if (token is Function) {
      yield handler(token);
    } else if (token is Type) {
      if (!reflectType(token).isAssignableTo(reflectType(Middleware))) {
        throw new TypeError('[$token] must be assignable to [Middleware]');
      }
      yield ioc.make(token);
    } else if (token is Iterable) {
      yield* resolveMiddleware(token);
    }
  }
}

typedef Future<Response> Pipeline(Request request);

typedef Pipeline PipelineFactory([IoCContainer container]);

class NoResponseFromPipelineException implements Exception {}

Middleware handler(Function handler) => new HandlerMiddleware(handler);

shelf.Middleware middleware(shelf.Middleware middleware) {
  return (shelf.Handler innerHandler) {
    return middleware(innerHandler);
  };
}

Middleware pipeIf(bool condition(Request request), [middlewareA = nothing, middlewareB = nothing, middlewareC = nothing,
middlewareD = nothing, middlewareE = nothing, middlewareF = nothing, middlewareG = nothing,
middlewareH = nothing, middlewareI = nothing, middlewareJ = nothing, middlewareK = nothing,
middlewareL = nothing, middlewareM = nothing, middlewareN = nothing, middlewareO = nothing,
middlewareP = nothing, middlewareQ = nothing, middlewareR = nothing, middlewareS = nothing,
middlewareT = nothing, middlewareU = nothing, middlewareV = nothing, middlewareW = nothing,
middlewareX = nothing, middlewareY = nothing, middlewareZ = nothing]) {
  return new ConditionalMiddleware(condition, pipe(middlewareA, middlewareB,
      middlewareC, middlewareD, middlewareE, middlewareF, middlewareG, middlewareH,
      middlewareI, middlewareJ, middlewareK, middlewareL, middlewareM, middlewareN,
      middlewareO, middlewareP, middlewareQ, middlewareR, middlewareS, middlewareT,
      middlewareU, middlewareV, middlewareW, middlewareX, middlewareY, middlewareZ));
}
