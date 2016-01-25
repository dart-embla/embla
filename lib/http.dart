import 'package:shelf/shelf.dart' as shelf hide Request, Response;
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf/shelf.dart' show Request, Response;
export 'package:shelf/shelf.dart' show Request, Response;
import 'dart:async';
import 'dart:mirrors';
import 'src/util/helper_container.dart';
import 'http_annotations.dart';
import 'package:container/container.dart';
import 'application.dart';
import 'dart:io' hide HttpException;
import 'src/http/route_expander.dart';
import 'src/http/response_maker.dart';
import 'src/http/http_exceptions.dart';
export 'src/http/http_exceptions.dart';

class Middleware {
  final ResponseMaker _responseMaker = new ResponseMaker();
  shelf.Handler _innerHandler;

  shelf.Handler call(shelf.Handler innerHandler) {
    _innerHandler = innerHandler;
    return handle;
  }

  Future<Response> handle(Request request) async {
    return await _innerHandler(request);
  }

  Response ok(anything) {
    return _responseMaker.parse(anything).status(200);
  }

  Response redirect(String location) {
    return new Response.found(location);
  }

  abort([int statusCode = 500, body = 'Something went wrong']) {
    throw new HttpException(statusCode, body);
  }

  abortBadRequest([body = 'Bad Request']) {
    throw new HttpBadRequestException(body);
  }

  abortUnauthorized([body = 'Unauthorized']) {
    throw new HttpUnauthorizedException(body);
  }

  abortPaymentRequired([body = 'Payment Required']) {
    throw new HttpPaymentRequiredException(body);
  }

  abortForbidden([body = 'Forbidden']) {
    throw new HttpForbiddenException(body);
  }

  abortNotFound([body = 'Not Found']) {
    throw new HttpNotFoundException(body);
  }

  abortMethodNotAllowed([body = 'Method Not Allowed']) {
    throw new HttpMethodNotAllowedException(body);
  }

  abortNotAcceptable([body = 'Not Acceptable']) {
    throw new HttpNotAcceptableException(body);
  }

  abortProxyAuthenticationRequired([body = 'Proxy Authentication Required']) {
    throw new HttpProxyAuthenticationRequiredException(body);
  }

  abortRequestTimeout([body = 'Request Timeout']) {
    throw new HttpRequestTimeoutException(body);
  }

  abortConflict([body = 'Conflict']) {
    throw new HttpConflictException(body);
  }

  abortGone([body = 'Gone']) {
    throw new HttpGoneException(body);
  }

  abortLengthRequired([body = 'Length Required']) {
    throw new HttpLengthRequiredException(body);
  }

  abortPreconditionFailed([body = 'Precondition Failed']) {
    throw new HttpPreconditionFailedException(body);
  }

  abortPayloadTooLarge([body = 'Payload Too Large']) {
    throw new HttpPayloadTooLargeException(body);
  }

  abortURITooLong([body = 'URI Too Long']) {
    throw new HttpURITooLongException(body);
  }

  abortUnsupportedMediaType([body = 'Unsupported Media Type']) {
    throw new HttpUnsupportedMediaTypeException(body);
  }

  abortRangeNotSatisfiable([body = 'Range Not Satisfiable']) {
    throw new HttpRangeNotSatisfiableException(body);
  }

  abortExpectationFailed([body = 'Expectation Failed']) {
    throw new HttpExpectationFailedException(body);
  }

  abortImATeapot([body = 'I\'m a Teapot']) {
    throw new HttpImATeapotException(body);
  }

  abortAuthenticationTimeout([body = 'Authentication Timeout']) {
    throw new HttpAuthenticationTimeoutException(body);
  }

  abortMisdirectedRequest([body = 'Misdirected Request']) {
    throw new HttpMisdirectedRequestException(body);
  }

  abortUnprocessableEntity([body = 'Unprocessable Entity']) {
    throw new HttpUnprocessableEntityException(body);
  }

  abortLocked([body = 'Locked']) {
    throw new HttpLockedException(body);
  }

  abortFailedDependency([body = 'Failed Dependency']) {
    throw new HttpFailedDependencyException(body);
  }

  abortUpgradeRequired([body = 'Upgrade Required']) {
    throw new HttpUpgradeRequiredException(body);
  }

  abortPreconditionRequired([body = 'Precondition Required']) {
    throw new HttpPreconditionRequiredException(body);
  }

  abortTooManyRequests([body = 'Too Many Requests']) {
    throw new HttpTooManyRequestsException(body);
  }

  abortRequestHeaderFieldsTooLarge([body = 'Request Header Fields Too Large']) {
    throw new HttpRequestHeaderFieldsTooLargeException(body);
  }

  abortInternalServerError([body = 'Internal Server Error']) {
    throw new HttpInternalServerErrorException(body);
  }

  abortNotImplemented([body = 'Not Implemented']) {
    throw new HttpNotImplementedException(body);
  }

  abortBadGateway([body = 'Bad Gateway']) {
    throw new HttpBadGatewayException(body);
  }

  abortServiceUnavailable([body = 'Service Unavailable']) {
    throw new HttpServiceUnavailableException(body);
  }

  abortGatewayTimeout([body = 'Gateway Timeout']) {
    throw new HttpGatewayTimeoutException(body);
  }

  abortVersionNotSupported([body = 'HTTP Version Not Supported']) {
    throw new HttpVersionNotSupportedException(body);
  }

  abortVariantAlsoNegotiates([body = 'Variant Also Negotiates']) {
    throw new HttpVariantAlsoNegotiatesException(body);
  }

  abortInsufficientStorage([body = 'Insufficient Storage']) {
    throw new HttpInsufficientStorageException(body);
  }

  abortLoopDetected([body = 'Loop Detected']) {
    throw new HttpLoopDetectedException(body);
  }

  abortNotExtended([body = 'Not Extended']) {
    throw new HttpNotExtendedException(body);
  }

  abortNetworkAuthenticationRequired(
      [body = 'Network Authentication Required']) {
    throw new HttpNetworkAuthenticationRequiredException(body);
  }
}

typedef Future<Response> Pipeline(Request request);

const _nothing = const _Nothing();

class _Nothing {
  const _Nothing();
}

Pipeline pipe(
    [middlewareA = _nothing, middlewareB = _nothing, middlewareC = _nothing,
    middlewareD = _nothing, middlewareE = _nothing, middlewareF = _nothing, middlewareG = _nothing,
    middlewareH = _nothing, middlewareI = _nothing, middlewareJ = _nothing, middlewareK = _nothing,
    middlewareL = _nothing, middlewareM = _nothing, middlewareN = _nothing, middlewareO = _nothing,
    middlewareP = _nothing, middlewareQ = _nothing, middlewareR = _nothing, middlewareS = _nothing,
    middlewareT = _nothing, middlewareU = _nothing, middlewareV = _nothing, middlewareW = _nothing,
    middlewareX = _nothing, middlewareY = _nothing, middlewareZ = _nothing]) {
  final Iterable middlewareTokens = [middlewareA, middlewareB,
    middlewareC, middlewareD, middlewareE, middlewareF, middlewareG, middlewareH,
    middlewareI, middlewareJ, middlewareK, middlewareL, middlewareM, middlewareN,
    middlewareO, middlewareP, middlewareQ, middlewareR, middlewareS, middlewareT,
    middlewareU, middlewareV, middlewareW, middlewareX, middlewareY, middlewareZ
  ].where((m) => m != _nothing);
  return _pipe(_resolveMiddleware(middlewareTokens));
}

Pipeline _pipe(Iterable<Middleware> middleware) {
  final shelf.Pipeline pipe = middleware.fold /*<shelf.Pipeline>*/(
      const shelf.Pipeline().addMiddleware(_noResponseToNotFound),
      (shelf.Pipeline pipeline, Middleware middleware) {
    return pipeline.addMiddleware(middleware);
  }) as shelf.Pipeline;
  final shelf.Handler handler = pipe.addHandler((Request request) {
    throw new NoResponseFromPipelineException();
  });

  return (Request request) async => handler(request);
}

shelf.Handler _noResponseToNotFound(shelf.Handler innerHandler) {
  return (Request request) async {
    try {
      return await innerHandler(request);
    } on NoResponseFromPipelineException {
      throw new HttpNotFoundException();
    }
  };
}

class NoResponseFromPipelineException implements Exception {}

Iterable<Middleware> _resolveMiddleware(Iterable tokens) sync* {
  for (final token in tokens) {
    if (token is Middleware) {
      yield token;
    } else if (token is Function) {
      yield handler(token);
    } else if (token is Type) {
      if (!reflectType(token).isAssignableTo(reflectType(Middleware))) {
        throw new Exception('[$token] must be an instance of [Middleware]');
      }
      yield helperContainer.make(token);
    } else if (token is Iterable) {
      yield* _resolveMiddleware(token);
    }
  }
}

class Route extends Middleware {
  final Iterable<String> methods;
  final String path;
  final Pipeline pipeline;
  final RouteExpander _expander = new RouteExpander();

  Route._(this.methods, this.path, this.pipeline);

  factory Route(
      Iterable<String> methods,
      String path,
      Pipeline pipeline) =>
      new Route._(
          methods.map((m) => m.toUpperCase()) as Iterable<String>,
          path.split('/').where((s) => s != '').join('/'),
          pipeline
      );

  RegExp get regexPath => new RegExp(_expander.expand(path));

  @override Future<Response> handle(Request request) async {
    if (!methods.contains(request.method)) {
      return await super.handle(request);
    }
    final url = request.url.path.split('/').where((s) => s.isNotEmpty).join('/');
    final wildcards = _expander.parseWildcards(path, url);
    if (regexPath.hasMatch(url)) {
      try {
        return await pipeline(request.change(
            path: _expander.prefix(path, url),
            context: {
              'embla:wildcards': new Map.unmodifiable(
                new Map.from(request.context['embla:wildcards'] ?? {})
                ..addAll(wildcards)
              )
            }
        ));
      } on NoResponseFromPipelineException {
        return await super.handle(request);
      }
    }

    return await super.handle(request);
  }

  static Route match(Iterable<String> methods, String path,
      [middlewareA = _nothing, middlewareB = _nothing, middlewareC = _nothing,
      middlewareD = _nothing, middlewareE = _nothing, middlewareF = _nothing, middlewareG = _nothing,
      middlewareH = _nothing, middlewareI = _nothing, middlewareJ = _nothing, middlewareK = _nothing,
      middlewareL = _nothing, middlewareM = _nothing, middlewareN = _nothing, middlewareO = _nothing,
      middlewareP = _nothing, middlewareQ = _nothing, middlewareR = _nothing, middlewareS = _nothing,
      middlewareT = _nothing, middlewareU = _nothing, middlewareV = _nothing, middlewareW = _nothing,
      middlewareX = _nothing, middlewareY = _nothing, middlewareZ = _nothing]) {
    return new Route(methods, path, pipe(middlewareA, middlewareB,
        middlewareC, middlewareD, middlewareE, middlewareF, middlewareG, middlewareH,
        middlewareI, middlewareJ, middlewareK, middlewareL, middlewareM, middlewareN,
        middlewareO, middlewareP, middlewareQ, middlewareR, middlewareS, middlewareT,
        middlewareU, middlewareV, middlewareW, middlewareX, middlewareY, middlewareZ));
  }

  static Route get(String path,
      [middlewareA = _nothing, middlewareB = _nothing, middlewareC = _nothing,
      middlewareD = _nothing, middlewareE = _nothing, middlewareF = _nothing, middlewareG = _nothing,
      middlewareH = _nothing, middlewareI = _nothing, middlewareJ = _nothing, middlewareK = _nothing,
      middlewareL = _nothing, middlewareM = _nothing, middlewareN = _nothing, middlewareO = _nothing,
      middlewareP = _nothing, middlewareQ = _nothing, middlewareR = _nothing, middlewareS = _nothing,
      middlewareT = _nothing, middlewareU = _nothing, middlewareV = _nothing, middlewareW = _nothing,
      middlewareX = _nothing, middlewareY = _nothing, middlewareZ = _nothing]) {
    return new Route(['GET', 'HEAD'], path, pipe(middlewareA, middlewareB,
        middlewareC, middlewareD, middlewareE, middlewareF, middlewareG, middlewareH,
        middlewareI, middlewareJ, middlewareK, middlewareL, middlewareM, middlewareN,
        middlewareO, middlewareP, middlewareQ, middlewareR, middlewareS, middlewareT,
        middlewareU, middlewareV, middlewareW, middlewareX, middlewareY, middlewareZ));
  }

  static Route post(String path,
      [middlewareA = _nothing, middlewareB = _nothing, middlewareC = _nothing,
      middlewareD = _nothing, middlewareE = _nothing, middlewareF = _nothing, middlewareG = _nothing,
      middlewareH = _nothing, middlewareI = _nothing, middlewareJ = _nothing, middlewareK = _nothing,
      middlewareL = _nothing, middlewareM = _nothing, middlewareN = _nothing, middlewareO = _nothing,
      middlewareP = _nothing, middlewareQ = _nothing, middlewareR = _nothing, middlewareS = _nothing,
      middlewareT = _nothing, middlewareU = _nothing, middlewareV = _nothing, middlewareW = _nothing,
      middlewareX = _nothing, middlewareY = _nothing, middlewareZ = _nothing]) {
    return new Route(['POST'], path, pipe(middlewareA, middlewareB,
        middlewareC, middlewareD, middlewareE, middlewareF, middlewareG, middlewareH,
        middlewareI, middlewareJ, middlewareK, middlewareL, middlewareM, middlewareN,
        middlewareO, middlewareP, middlewareQ, middlewareR, middlewareS, middlewareT,
        middlewareU, middlewareV, middlewareW, middlewareX, middlewareY, middlewareZ));
  }

  static Route put(String path,
      [middlewareA = _nothing, middlewareB = _nothing, middlewareC = _nothing,
      middlewareD = _nothing, middlewareE = _nothing, middlewareF = _nothing, middlewareG = _nothing,
      middlewareH = _nothing, middlewareI = _nothing, middlewareJ = _nothing, middlewareK = _nothing,
      middlewareL = _nothing, middlewareM = _nothing, middlewareN = _nothing, middlewareO = _nothing,
      middlewareP = _nothing, middlewareQ = _nothing, middlewareR = _nothing, middlewareS = _nothing,
      middlewareT = _nothing, middlewareU = _nothing, middlewareV = _nothing, middlewareW = _nothing,
      middlewareX = _nothing, middlewareY = _nothing, middlewareZ = _nothing]) {
    return new Route(['PUT'], path, pipe(middlewareA, middlewareB,
        middlewareC, middlewareD, middlewareE, middlewareF, middlewareG, middlewareH,
        middlewareI, middlewareJ, middlewareK, middlewareL, middlewareM, middlewareN,
        middlewareO, middlewareP, middlewareQ, middlewareR, middlewareS, middlewareT,
        middlewareU, middlewareV, middlewareW, middlewareX, middlewareY, middlewareZ));
  }

  static Route patch(String path,
      [middlewareA = _nothing, middlewareB = _nothing, middlewareC = _nothing,
      middlewareD = _nothing, middlewareE = _nothing, middlewareF = _nothing, middlewareG = _nothing,
      middlewareH = _nothing, middlewareI = _nothing, middlewareJ = _nothing, middlewareK = _nothing,
      middlewareL = _nothing, middlewareM = _nothing, middlewareN = _nothing, middlewareO = _nothing,
      middlewareP = _nothing, middlewareQ = _nothing, middlewareR = _nothing, middlewareS = _nothing,
      middlewareT = _nothing, middlewareU = _nothing, middlewareV = _nothing, middlewareW = _nothing,
      middlewareX = _nothing, middlewareY = _nothing, middlewareZ = _nothing]) {
    return new Route(['PATCH'], path, pipe(middlewareA, middlewareB,
        middlewareC, middlewareD, middlewareE, middlewareF, middlewareG, middlewareH,
        middlewareI, middlewareJ, middlewareK, middlewareL, middlewareM, middlewareN,
        middlewareO, middlewareP, middlewareQ, middlewareR, middlewareS, middlewareT,
        middlewareU, middlewareV, middlewareW, middlewareX, middlewareY, middlewareZ));
  }

  static Route update(String path,
      [middlewareA = _nothing, middlewareB = _nothing, middlewareC = _nothing,
      middlewareD = _nothing, middlewareE = _nothing, middlewareF = _nothing, middlewareG = _nothing,
      middlewareH = _nothing, middlewareI = _nothing, middlewareJ = _nothing, middlewareK = _nothing,
      middlewareL = _nothing, middlewareM = _nothing, middlewareN = _nothing, middlewareO = _nothing,
      middlewareP = _nothing, middlewareQ = _nothing, middlewareR = _nothing, middlewareS = _nothing,
      middlewareT = _nothing, middlewareU = _nothing, middlewareV = _nothing, middlewareW = _nothing,
      middlewareX = _nothing, middlewareY = _nothing, middlewareZ = _nothing]) {
    return new Route(['UPDATE'], path, pipe(middlewareA, middlewareB,
        middlewareC, middlewareD, middlewareE, middlewareF, middlewareG, middlewareH,
        middlewareI, middlewareJ, middlewareK, middlewareL, middlewareM, middlewareN,
        middlewareO, middlewareP, middlewareQ, middlewareR, middlewareS, middlewareT,
        middlewareU, middlewareV, middlewareW, middlewareX, middlewareY, middlewareZ));
  }

  static Route delete(String path,
      [middlewareA = _nothing, middlewareB = _nothing, middlewareC = _nothing,
      middlewareD = _nothing, middlewareE = _nothing, middlewareF = _nothing, middlewareG = _nothing,
      middlewareH = _nothing, middlewareI = _nothing, middlewareJ = _nothing, middlewareK = _nothing,
      middlewareL = _nothing, middlewareM = _nothing, middlewareN = _nothing, middlewareO = _nothing,
      middlewareP = _nothing, middlewareQ = _nothing, middlewareR = _nothing, middlewareS = _nothing,
      middlewareT = _nothing, middlewareU = _nothing, middlewareV = _nothing, middlewareW = _nothing,
      middlewareX = _nothing, middlewareY = _nothing, middlewareZ = _nothing]) {
    return new Route(['DELETE'], path, pipe(middlewareA, middlewareB,
        middlewareC, middlewareD, middlewareE, middlewareF, middlewareG, middlewareH,
        middlewareI, middlewareJ, middlewareK, middlewareL, middlewareM, middlewareN,
        middlewareO, middlewareP, middlewareQ, middlewareR, middlewareS, middlewareT,
        middlewareU, middlewareV, middlewareW, middlewareX, middlewareY, middlewareZ));
  }

  static Route options(String path,
      [middlewareA = _nothing, middlewareB = _nothing, middlewareC = _nothing,
      middlewareD = _nothing, middlewareE = _nothing, middlewareF = _nothing, middlewareG = _nothing,
      middlewareH = _nothing, middlewareI = _nothing, middlewareJ = _nothing, middlewareK = _nothing,
      middlewareL = _nothing, middlewareM = _nothing, middlewareN = _nothing, middlewareO = _nothing,
      middlewareP = _nothing, middlewareQ = _nothing, middlewareR = _nothing, middlewareS = _nothing,
      middlewareT = _nothing, middlewareU = _nothing, middlewareV = _nothing, middlewareW = _nothing,
      middlewareX = _nothing, middlewareY = _nothing, middlewareZ = _nothing]) {
    return new Route(['OPTIONS'], path, pipe(middlewareA, middlewareB,
        middlewareC, middlewareD, middlewareE, middlewareF, middlewareG, middlewareH,
        middlewareI, middlewareJ, middlewareK, middlewareL, middlewareM, middlewareN,
        middlewareO, middlewareP, middlewareQ, middlewareR, middlewareS, middlewareT,
        middlewareU, middlewareV, middlewareW, middlewareX, middlewareY, middlewareZ));
  }

  static Route all(String path,
      [middlewareA = _nothing, middlewareB = _nothing, middlewareC = _nothing,
      middlewareD = _nothing, middlewareE = _nothing, middlewareF = _nothing, middlewareG = _nothing,
      middlewareH = _nothing, middlewareI = _nothing, middlewareJ = _nothing, middlewareK = _nothing,
      middlewareL = _nothing, middlewareM = _nothing, middlewareN = _nothing, middlewareO = _nothing,
      middlewareP = _nothing, middlewareQ = _nothing, middlewareR = _nothing, middlewareS = _nothing,
      middlewareT = _nothing, middlewareU = _nothing, middlewareV = _nothing, middlewareW = _nothing,
      middlewareX = _nothing, middlewareY = _nothing, middlewareZ = _nothing]) {
    return new Route(['GET', 'HEAD', 'OPTIONS', 'POST', 'PUT', 'PATCH', 'UPDATE', 'DELETE'],
        path, pipe(middlewareA, middlewareB,
        middlewareC, middlewareD, middlewareE, middlewareF, middlewareG, middlewareH,
        middlewareI, middlewareJ, middlewareK, middlewareL, middlewareM, middlewareN,
        middlewareO, middlewareP, middlewareQ, middlewareR, middlewareS, middlewareT,
        middlewareU, middlewareV, middlewareW, middlewareX, middlewareY, middlewareZ));
  }
}

Middleware handler(Function handler) => new HandlerMiddleware(handler, helperContainer);

class HandlerMiddleware extends Middleware {
  final Function handler;
  final Container container;

  HandlerMiddleware(this.handler, this.container);

  @override Future<Response> handle(Request request) async {
    final returnValue = await container.resolve(handler, injecting: {
      Request: request
    }, namedParameters: request.context['embla:wildcards'] as Map<String, String>);

    if (returnValue is Response) return returnValue;

    return ok(returnValue);
  }
}

abstract class Controller extends Middleware {
  Pipeline __pipeline;
  Pipeline get _pipeline => __pipeline ??= _buildPipeline();

  Pipeline _buildPipeline() {
    final mirror = reflect(this);
    final routeMethods = mirror.type
        .instanceMembers.values
        .where((m) => m.metadata
        .any((i) => i.reflectee is RouteHandler));
    return _pipe(_resolveRoutes(mirror, routeMethods));
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

  @override Future<Response> handle(Request request) async {
    try {
      return await _pipeline(request);
    } on NoResponseFromPipelineException {
      return await super.handle(request);
    }
  }
}

class HttpBootstrapper extends Bootstrapper {
  final Pipeline pipeline;
  final String host;
  final int port;
  final ResponseMaker _responseMaker = new ResponseMaker();

  HttpBootstrapper({
  this.host: 'localhost',
  this.port: 1337,
  this.pipeline
  });

  @Hook.bindings
  bindings() async {
    container.singleton(await HttpServer.bind(this.host, this.port), as: HttpServer);
    container.singleton(pipeline, as: Pipeline);
  }

  @Hook.interaction
  start(HttpServer server) {
    server.listen((request) {
      shelf_io.handleRequest(request, (Request request) async {
        try {
          return await pipeline(request);
        } on HttpException catch(e) {
          return _responseMaker.parse(e.body).status(e.statusCode);
        }
      });
    });
    print('<blue>Server started on <underline>http://${server.address.host}:${server.port}</underline></blue>');
  }

  @Hook.exit
  stop(HttpServer server) async {
    await server.close();
    print('<blue>Server stopped</blue>');
  }
}
