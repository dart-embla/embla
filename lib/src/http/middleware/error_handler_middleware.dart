import 'dart:async';
import 'dart:mirrors';

import 'package:stack_trace/stack_trace.dart';

import '../../http/helpers.dart';
import '../../util/helper_container.dart';
import '../../util/nothing.dart';
import '../middleware.dart';
import '../pipeline.dart';
import '../request_response.dart';
import 'handler_middleware.dart';
import '../../http/error_template.dart';

class BadErrorHandlerOrderException implements Exception {
  final String message;

  BadErrorHandlerOrderException(this.message);

  String toString() => 'BadErrorHandlerOrderException: $message';
}

class ErrorHandlerCollection extends Middleware {
  final ErrorTemplate _errorTemplate = new ErrorTemplate();
  final Map<Type, Pipeline> _catches;

  ErrorHandlerCollection([this._catches = const {}]);

  Future<Response> handle(Request request) {
    return super.handle(request).catchError((e, s) => _catch(request, e, s)) as Future<Response>;
  }

  ErrorHandlerCollection on(Type errorType, middlewareA, [middlewareB = nothing, middlewareC = nothing,
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
    for (final type in _catches.keys) {
      if (reflectType(type).isSubtypeOf(reflectType(errorType))) {
        throw new BadErrorHandlerOrderException(
          "$type is a subtype of $errorType and should therefore be "
          "added after $errorType in the handler chain.\n\n"
          "    ErrorHandlerMiddleware\n"
          "      .on($errorType, _handle$errorType)\n"
          "      .on($type, _handle$type);\n"
        );
      }
    }
    return new ErrorHandlerCollection(
      <Type, Pipeline>{}
      ..addAll(_catches)
      ..addAll({errorType: pipeActual(resolveMiddleware(middlewareTokens))})
    );
  }

  Future<Response> _catch(Request request, error, StackTrace stack) async {
    final mirror = reflect(error);
    for (final type in _catches.keys) {
      if (mirror.type.isAssignableTo(reflectType(type))) {
        return applyInjections({
          error.runtimeType: error,
          type: error,
          StackTrace: stack,
          Chain: new Chain.forTrace(stack)
        })(_catches[type])(request);
      }
    }
    return _errorTemplate.catchError(error, stack);
  }
}

class ErrorHandlerMiddleware extends Middleware {
  final ErrorHandlerCollection _emptyCollection = new ErrorHandlerCollection();

  Future<Response> handle(Request request) async {
    return await _emptyCollection.call(super.handle)(request);
  }

  static ErrorHandlerCollection catchAll(Function handler) {
    return new ErrorHandlerCollection({dynamic: pipeActual(resolveMiddleware([
      new HandlerMiddleware(handler, helperContainer)
    ]))});
  }

  static ErrorHandlerCollection on(Type errorType, middlewareA, [middlewareB = nothing, middlewareC = nothing,
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
    return new ErrorHandlerCollection({errorType: pipeActual(resolveMiddleware(middlewareTokens))});
  }
}
