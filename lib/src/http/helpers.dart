import 'package:shelf/shelf.dart' as shelf hide Request, Response;
import 'request_response.dart';

import '../http/middleware.dart';
import '../util/concat.dart';

shelf.Middleware applyInjections(Map<Type, Object> injections) {
  return (shelf.Handler innerHandler) {
    return (Request request) {
      return innerHandler(request.change(
          context: {
            'embla:injections': concatMaps/*<Type, Object>*/(
              (request.context['embla:injections'] ?? {}) as Map<Type, Object>,
              injections
            )
          }
      ));
    };
  };
}

shelf.Middleware applyLocals(Map<String, dynamic> locals) {
  return (shelf.Handler innerHandler) {
    return (Request request) {
      return innerHandler(request.change(
          context: {
            'embla:locals': concatMaps((request.context['embla:locals'] ?? {}) as Map<String, dynamic>, locals)
          }
      ));
    };
  };
}
