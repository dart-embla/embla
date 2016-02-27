import 'middleware.dart';
import 'pipeline.dart';
import 'request_response.dart';
import 'dart:async';
import 'dart:mirrors';
import '../../http_annotations.dart';
import '../util/nothing.dart';
import 'route_expander.dart';

abstract class Controller extends Middleware {
  Pipeline __pipeline;
  Pipeline get _pipeline => __pipeline ??= _buildPipeline();

  @override Future<Response> handle(Request request) async {
    try {
      return await _pipeline(request);
    } on NoResponseFromPipelineException {
      return await super.handle(request);
    }
  }

  Pipeline _buildPipeline() {
    final mirror = reflect(this);
    final routeMethods = mirror.type
        .instanceMembers.values
        .where((m) => m.metadata
        .any((i) => i.reflectee is RouteHandler));
    return pipeActual(_resolveRoutes(mirror, routeMethods));
  }

  Iterable<Middleware> _resolveRoutes(
      InstanceMirror mirror,
      Iterable<MethodMirror> routeMethods
      ) sync* {
    for (final routeMethod in routeMethods) {
      final annotations = routeMethod.metadata
          .where((i) => i.reflectee is RouteHandler)
          .map((i) => i.reflectee as RouteHandler);
      for (final annotation in annotations) {
        final Function method = mirror.getField(routeMethod.simpleName).reflectee;
        final fallback = MirrorSystem.getName(routeMethod.simpleName);
        yield annotation.toHandler(method, fallback == 'index' ? '' : fallback);
      }
    }
  }
}

class Route extends Middleware {
  final Iterable<String> methods;
  final String path;
  final PipelineFactory pipeline;
  final RouteExpander _expander = new RouteExpander();

  Pipeline __pipeline;

  factory Route(
      Iterable<String> methods,
      String path,
      PipelineFactory pipeline) =>
      new Route._(
          methods.map((m) => m.toUpperCase()),
          path.split('/').where((s) => s != '').join('/'),
          pipeline
      );

  Route._(this.methods, this.path, this.pipeline);

  RegExp get regexPath => new RegExp(_expander.expand(path));
  Pipeline get _pipeline => (__pipeline ??= pipeline()) as Pipeline;

  @override Future<Response> handle(Request request) async {
    if (!methods.contains(request.method)) {
      return await super.handle(request);
    }
    final url = request.url.path.split('/').where((s) => s.isNotEmpty).join('/');
    final wildcards = _expander.parseWildcards(path, url);
    if (regexPath.hasMatch(url)) {
      try {
        for (final wc in wildcards.keys) {
          context.container = context.container
            .bindName(wc, to: wildcards[wc]);
        }
        return await pipeline()(request.change(
            path: _expander.prefix(path, url)
        ));
      } on NoResponseFromPipelineException {
        return await super.handle(request);
      }
    }

    return await super.handle(request);
  }

  static Route all(String path,
      [middlewareA = nothing, middlewareB = nothing, middlewareC = nothing,
      middlewareD = nothing, middlewareE = nothing, middlewareF = nothing, middlewareG = nothing,
      middlewareH = nothing, middlewareI = nothing, middlewareJ = nothing, middlewareK = nothing,
      middlewareL = nothing, middlewareM = nothing, middlewareN = nothing, middlewareO = nothing,
      middlewareP = nothing, middlewareQ = nothing, middlewareR = nothing, middlewareS = nothing,
      middlewareT = nothing, middlewareU = nothing, middlewareV = nothing, middlewareW = nothing,
      middlewareX = nothing, middlewareY = nothing, middlewareZ = nothing]) {
    return new Route(['GET', 'HEAD', 'OPTIONS', 'POST', 'PUT', 'PATCH', 'UPDATE', 'DELETE'],
        path, pipe(middlewareA, middlewareB,
            middlewareC, middlewareD, middlewareE, middlewareF, middlewareG, middlewareH,
            middlewareI, middlewareJ, middlewareK, middlewareL, middlewareM, middlewareN,
            middlewareO, middlewareP, middlewareQ, middlewareR, middlewareS, middlewareT,
            middlewareU, middlewareV, middlewareW, middlewareX, middlewareY, middlewareZ));
  }

  static Route delete(String path,
      [middlewareA = nothing, middlewareB = nothing, middlewareC = nothing,
      middlewareD = nothing, middlewareE = nothing, middlewareF = nothing, middlewareG = nothing,
      middlewareH = nothing, middlewareI = nothing, middlewareJ = nothing, middlewareK = nothing,
      middlewareL = nothing, middlewareM = nothing, middlewareN = nothing, middlewareO = nothing,
      middlewareP = nothing, middlewareQ = nothing, middlewareR = nothing, middlewareS = nothing,
      middlewareT = nothing, middlewareU = nothing, middlewareV = nothing, middlewareW = nothing,
      middlewareX = nothing, middlewareY = nothing, middlewareZ = nothing]) {
    return new Route(['DELETE'], path, pipe(middlewareA, middlewareB,
        middlewareC, middlewareD, middlewareE, middlewareF, middlewareG, middlewareH,
        middlewareI, middlewareJ, middlewareK, middlewareL, middlewareM, middlewareN,
        middlewareO, middlewareP, middlewareQ, middlewareR, middlewareS, middlewareT,
        middlewareU, middlewareV, middlewareW, middlewareX, middlewareY, middlewareZ));
  }

  static Route get(String path,
      [middlewareA = nothing, middlewareB = nothing, middlewareC = nothing,
      middlewareD = nothing, middlewareE = nothing, middlewareF = nothing, middlewareG = nothing,
      middlewareH = nothing, middlewareI = nothing, middlewareJ = nothing, middlewareK = nothing,
      middlewareL = nothing, middlewareM = nothing, middlewareN = nothing, middlewareO = nothing,
      middlewareP = nothing, middlewareQ = nothing, middlewareR = nothing, middlewareS = nothing,
      middlewareT = nothing, middlewareU = nothing, middlewareV = nothing, middlewareW = nothing,
      middlewareX = nothing, middlewareY = nothing, middlewareZ = nothing]) {
    return new Route(['GET', 'HEAD'], path, pipe(middlewareA, middlewareB,
        middlewareC, middlewareD, middlewareE, middlewareF, middlewareG, middlewareH,
        middlewareI, middlewareJ, middlewareK, middlewareL, middlewareM, middlewareN,
        middlewareO, middlewareP, middlewareQ, middlewareR, middlewareS, middlewareT,
        middlewareU, middlewareV, middlewareW, middlewareX, middlewareY, middlewareZ));
  }

  static Route match(Iterable<String> methods, String path,
      [middlewareA = nothing, middlewareB = nothing, middlewareC = nothing,
      middlewareD = nothing, middlewareE = nothing, middlewareF = nothing, middlewareG = nothing,
      middlewareH = nothing, middlewareI = nothing, middlewareJ = nothing, middlewareK = nothing,
      middlewareL = nothing, middlewareM = nothing, middlewareN = nothing, middlewareO = nothing,
      middlewareP = nothing, middlewareQ = nothing, middlewareR = nothing, middlewareS = nothing,
      middlewareT = nothing, middlewareU = nothing, middlewareV = nothing, middlewareW = nothing,
      middlewareX = nothing, middlewareY = nothing, middlewareZ = nothing]) {
    return new Route(methods, path, pipe(middlewareA, middlewareB,
        middlewareC, middlewareD, middlewareE, middlewareF, middlewareG, middlewareH,
        middlewareI, middlewareJ, middlewareK, middlewareL, middlewareM, middlewareN,
        middlewareO, middlewareP, middlewareQ, middlewareR, middlewareS, middlewareT,
        middlewareU, middlewareV, middlewareW, middlewareX, middlewareY, middlewareZ));
  }

  static Route options(String path,
      [middlewareA = nothing, middlewareB = nothing, middlewareC = nothing,
      middlewareD = nothing, middlewareE = nothing, middlewareF = nothing, middlewareG = nothing,
      middlewareH = nothing, middlewareI = nothing, middlewareJ = nothing, middlewareK = nothing,
      middlewareL = nothing, middlewareM = nothing, middlewareN = nothing, middlewareO = nothing,
      middlewareP = nothing, middlewareQ = nothing, middlewareR = nothing, middlewareS = nothing,
      middlewareT = nothing, middlewareU = nothing, middlewareV = nothing, middlewareW = nothing,
      middlewareX = nothing, middlewareY = nothing, middlewareZ = nothing]) {
    return new Route(['OPTIONS'], path, pipe(middlewareA, middlewareB,
        middlewareC, middlewareD, middlewareE, middlewareF, middlewareG, middlewareH,
        middlewareI, middlewareJ, middlewareK, middlewareL, middlewareM, middlewareN,
        middlewareO, middlewareP, middlewareQ, middlewareR, middlewareS, middlewareT,
        middlewareU, middlewareV, middlewareW, middlewareX, middlewareY, middlewareZ));
  }

  static Route patch(String path,
      [middlewareA = nothing, middlewareB = nothing, middlewareC = nothing,
      middlewareD = nothing, middlewareE = nothing, middlewareF = nothing, middlewareG = nothing,
      middlewareH = nothing, middlewareI = nothing, middlewareJ = nothing, middlewareK = nothing,
      middlewareL = nothing, middlewareM = nothing, middlewareN = nothing, middlewareO = nothing,
      middlewareP = nothing, middlewareQ = nothing, middlewareR = nothing, middlewareS = nothing,
      middlewareT = nothing, middlewareU = nothing, middlewareV = nothing, middlewareW = nothing,
      middlewareX = nothing, middlewareY = nothing, middlewareZ = nothing]) {
    return new Route(['PATCH'], path, pipe(middlewareA, middlewareB,
        middlewareC, middlewareD, middlewareE, middlewareF, middlewareG, middlewareH,
        middlewareI, middlewareJ, middlewareK, middlewareL, middlewareM, middlewareN,
        middlewareO, middlewareP, middlewareQ, middlewareR, middlewareS, middlewareT,
        middlewareU, middlewareV, middlewareW, middlewareX, middlewareY, middlewareZ));
  }

  static Route post(String path,
      [middlewareA = nothing, middlewareB = nothing, middlewareC = nothing,
      middlewareD = nothing, middlewareE = nothing, middlewareF = nothing, middlewareG = nothing,
      middlewareH = nothing, middlewareI = nothing, middlewareJ = nothing, middlewareK = nothing,
      middlewareL = nothing, middlewareM = nothing, middlewareN = nothing, middlewareO = nothing,
      middlewareP = nothing, middlewareQ = nothing, middlewareR = nothing, middlewareS = nothing,
      middlewareT = nothing, middlewareU = nothing, middlewareV = nothing, middlewareW = nothing,
      middlewareX = nothing, middlewareY = nothing, middlewareZ = nothing]) {
    return new Route(['POST'], path, pipe(middlewareA, middlewareB,
        middlewareC, middlewareD, middlewareE, middlewareF, middlewareG, middlewareH,
        middlewareI, middlewareJ, middlewareK, middlewareL, middlewareM, middlewareN,
        middlewareO, middlewareP, middlewareQ, middlewareR, middlewareS, middlewareT,
        middlewareU, middlewareV, middlewareW, middlewareX, middlewareY, middlewareZ));
  }

  static Route put(String path,
      [middlewareA = nothing, middlewareB = nothing, middlewareC = nothing,
      middlewareD = nothing, middlewareE = nothing, middlewareF = nothing, middlewareG = nothing,
      middlewareH = nothing, middlewareI = nothing, middlewareJ = nothing, middlewareK = nothing,
      middlewareL = nothing, middlewareM = nothing, middlewareN = nothing, middlewareO = nothing,
      middlewareP = nothing, middlewareQ = nothing, middlewareR = nothing, middlewareS = nothing,
      middlewareT = nothing, middlewareU = nothing, middlewareV = nothing, middlewareW = nothing,
      middlewareX = nothing, middlewareY = nothing, middlewareZ = nothing]) {
    return new Route(['PUT'], path, pipe(middlewareA, middlewareB,
        middlewareC, middlewareD, middlewareE, middlewareF, middlewareG, middlewareH,
        middlewareI, middlewareJ, middlewareK, middlewareL, middlewareM, middlewareN,
        middlewareO, middlewareP, middlewareQ, middlewareR, middlewareS, middlewareT,
        middlewareU, middlewareV, middlewareW, middlewareX, middlewareY, middlewareZ));
  }

  static Route update(String path,
      [middlewareA = nothing, middlewareB = nothing, middlewareC = nothing,
      middlewareD = nothing, middlewareE = nothing, middlewareF = nothing, middlewareG = nothing,
      middlewareH = nothing, middlewareI = nothing, middlewareJ = nothing, middlewareK = nothing,
      middlewareL = nothing, middlewareM = nothing, middlewareN = nothing, middlewareO = nothing,
      middlewareP = nothing, middlewareQ = nothing, middlewareR = nothing, middlewareS = nothing,
      middlewareT = nothing, middlewareU = nothing, middlewareV = nothing, middlewareW = nothing,
      middlewareX = nothing, middlewareY = nothing, middlewareZ = nothing]) {
    return new Route(['UPDATE'], path, pipe(middlewareA, middlewareB,
        middlewareC, middlewareD, middlewareE, middlewareF, middlewareG, middlewareH,
        middlewareI, middlewareJ, middlewareK, middlewareL, middlewareM, middlewareN,
        middlewareO, middlewareP, middlewareQ, middlewareR, middlewareS, middlewareT,
        middlewareU, middlewareV, middlewareW, middlewareX, middlewareY, middlewareZ));
  }
}
