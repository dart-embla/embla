import 'package:quark/unit.dart';
import 'package:embla/http_basic_middleware.dart';
import 'package:embla/src/http/request_response.dart';
import 'middleware_call.dart';
import 'dart:convert';
export 'package:quark/init.dart';

class InputParserMiddlewareTest extends UnitTest {
  @test
  itWorksForGetRequests() async {
    final middleware = new InputParserMiddleware();
    final request = new Request('GET', new Uri.http('localhost', '/', {'k': 'v'}));
    await expectMiddlewareResponseBody(
        middleware,
        '{"k":"v"}',
        request,
        (request) => new Response.ok(
            JSON.encode(
                (request.context['embla:injections'] as Map<Type, Input>)[Input].toJson()
            )
        )
    );
  }

  @test
  itWorksForPostRequests() async {
    final middleware = new InputParserMiddleware();
    final request = new Request(
        'POST',
        new Uri.http('localhost', '/'),
        body: JSON.encode({'k': 'v'}),
        headers: {'Content-Type': 'application/json'}
    );
    await expectMiddlewareResponseBody(
        middleware,
        '{"k":"v"}',
        request,
        (request) => new Response.ok(
            JSON.encode(
                (request.context['embla:injections'] as Map<Type, Input>)[Input].toJson()
            )
        )
    );
  }
}