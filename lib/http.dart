import 'package:shelf/shelf_io.dart' as shelf_io;
import 'dart:io' hide HttpException;
import 'application.dart';
import 'src/http/response_maker.dart';
import 'src/http/pipeline.dart';
import 'src/http/request_response.dart';
import 'src/http/http_exceptions.dart';
import 'src/util/trace_formatting.dart';
import 'dart:async';
import 'dart:convert';

import 'src/http/context.dart';
export 'src/http/http_exceptions.dart';
export 'src/http/request_response.dart';
export 'src/http/pipeline.dart';
export 'src/http/middleware.dart';
export 'src/http/routing.dart';

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
    return container
      .bind(HttpServer, to: await _serverFactory(this.host, this.port));
  }

  @Hook.interaction
  start(HttpServer server) {
    final pipe = pipeline(container);
    server.autoCompress = true;
    server.listen((request) {
      request.response.bufferOutput = true;
      shelf_io.handleRequest(
        request,
        (_) => handleRequest(_, pipe).then((r) {
          final c = new StreamController<List<int>>();

          r.read().listen(c.add, onDone: c.close, onError: (e, s) {
            c.add(UTF8.encode("""
              <hr>
              <p>
                An error was thrown after headers were sent.
              </p>
              <h3>${e.toString().replaceAll("<", "&lt;")}</h3>
              <pre>${s.toString().replaceAll("<", "&lt;")}</pre>
              <hr>
            """));
          });

          return r.change(body: c.stream);
        })
      );
    });
    print('<blue>Server started on <underline>http://${server.address.host}:${server.port}</underline></blue>');
  }

  Future<Response> handleRequest(Request request, Pipeline pipe) async {
    Future<Response> run() async {
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
    return runInContext/*<Future<Response>>*/(container, run);
  }

  @Hook.exit
  stop(HttpServer server) async {
    await server.close();
    print('<blue>Server stopped</blue>');
  }
}
