import 'dart:async';
import 'package:embla/http.dart';
import 'package:test/test.dart';
import 'package:shelf/shelf.dart' as shelf;

Future<Response> middlewareCall(Middleware middleware, [Request request, shelf.Handler handler]) async {
  return await middleware
      .call((handler ?? (_) => throw new NoResponseFromPipelineException()) as shelf.Handler)
      (request ?? new Request('GET', new Uri.http('localhost', '/')));
}

Future expectMiddlewareResponseBody(Middleware middleware, String expectedBody, [Request request, shelf.Handler handler]) async {
  final response = await middlewareCall(middleware, request, handler);
  expect(await response.readAsString(), expectedBody);
}
