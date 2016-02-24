import 'dart:async';

import 'package:container/container.dart';

import '../middleware.dart';
import '../../util/concat.dart';
import '../request_response.dart';

class HandlerMiddleware extends Middleware {
  final Function handler;
  final Container container;

  HandlerMiddleware(this.handler, this.container);

  @override Future<Response> handle(Request request) async {
    final Map<Type, Object> injections = request.context['embla:injections'] as Map<Type, Object>;
    final returnValue = await container.resolve(handler,
        injecting: concatMaps/*<Type, dynamic>*/(
          (injections ?? {}) as Map<Type, dynamic>,
          <Type, dynamic>{Request: request}
        ),
        namedParameters: request.context['embla:wildcards'] as Map<String, String>
    );

    if (returnValue is Response) return returnValue;

    return ok(returnValue);
  }
}
