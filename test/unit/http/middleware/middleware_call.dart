import 'dart:async';
import 'package:embla/http.dart';
import 'package:test/test.dart';

Future<Response> middlewareCall(Middleware middleware) async {
  return await middleware
      .call((_) => throw new NoResponseFromPipelineException())
      (new Request('GET', new Uri.http('localhost', '/')));
}

Future expectMiddlewareResponseBody(Middleware middleware, String expectedBody) async {
  final response = await middlewareCall(middleware);
  expect(await response.readAsString(), expectedBody);
}