import 'package:shelf/shelf_io.dart' as shelf_io;
import 'dart:io' hide HttpException;
import 'application.dart';
import 'src/http/response_maker.dart';
import 'src/http/pipeline.dart';
import 'src/http/request_response.dart';
import 'src/http/http_exceptions.dart';
import 'src/util/trace_formatting.dart';
import 'dart:async';

export 'src/http/http_exceptions.dart';
export 'src/http/request_response.dart';
export 'src/http/pipeline.dart';
export 'src/http/middleware.dart';
export 'src/http/routing.dart';
export 'src/http/helpers.dart';

typedef Future<HttpServer> ServerFactory(dynamic host, int port);

class HttpBootstrapper extends Bootstrapper {
  final PipelineFactory pipeline;
  final String host;
  final int port;
  final ResponseMaker _responseMaker = new ResponseMaker();
  final ServerFactory _serverFactory;

  factory HttpBootstrapper({
    String host: 'localhost',
    int port: 1337,
    PipelineFactory pipeline
  }) {
    return new HttpBootstrapper.internal(
        HttpServer.bind,
        host,
        port,
        pipeline
    );
  }

  HttpBootstrapper.internal(
    this._serverFactory,
    this.host,
    this.port,
    this.pipeline
  );

  @Hook.bindings
  bindings() async {
    container.singleton(await _serverFactory(this.host, this.port), as: HttpServer);
    container.singleton(pipeline, as: Pipeline);
  }

  @Hook.interaction
  start(HttpServer server) {
    final pipe = pipeline();
    server.listen((request) {
      shelf_io.handleRequest(request, (_) => handleRequest(_, pipe));
    });
    print('<blue>Server started on <underline>http://${server.address.host}:${server.port}</underline></blue>');
  }

  Future<Response> handleRequest(Request request, Pipeline pipe) async {
    try {
      return await pipe(request);
    } on NoResponseFromPipelineException {
      return new Response.notFound('Not Found');
    } on HttpException catch(e) {
      return _responseMaker.parse(e.body).status(e.statusCode);
    } catch(e, s) {
      TraceFormatter.print(e, s);
      return new Response.internalServerError(body: 'Internal Server Error');
    }
  }

  @Hook.exit
  stop(HttpServer server) async {
    await server.close();
    print('<blue>Server stopped</blue>');
  }
}
