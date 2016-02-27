import 'package:quark/unit.dart';
export 'package:quark/init.dart';
import 'package:embla/src/http/middleware/handler_middleware.dart';
import 'dart:async';
import 'middleware_call.dart';
import 'package:embla/src/http/context.dart';

class HandlerMiddlewareTest extends UnitTest {
  @before
  setUp() {
    setUpContextForTesting();
  }

  Future expectResponse(Function handler, String expectedBody) async {
    final middleware = new HandlerMiddleware(handler);
    await expectMiddlewareResponseBody(middleware, expectedBody);
  }

  @test
  itWorks() async {
    await expectResponse(() => 'x', 'x');
  }

  @test
  itEncodesJson() async {
    await expectResponse(() => {'key': 'value'}, '{"key":"value"}');
  }

  @test
  itEncodesClasses() async {
    await expectResponse(() => new ValueObject('x'), '{"property":"x"}');
  }

  @test
  itSupportsInjection() async {
    final middleware = new HandlerMiddleware((ValueObject obj) => obj);
    middleware.context.container = middleware.context.container
      .bind(ValueObject, to: new ValueObject('y'));
    await expectMiddlewareResponseBody(middleware, '{"property":"y"}');
  }
}

class ValueObject {
  final String property;

  ValueObject([this.property]);
}
