import 'package:quark/unit.dart';
export 'package:quark/init.dart';
import 'package:container/container.dart';
import 'package:embla/src/http/middleware/handler_middleware.dart';
import 'dart:async';
import 'middleware_call.dart';

class HandlerMiddlewareTest extends UnitTest {
  Future expectResponse(Function handler, String expectedBody, [Container container]) async {
    final middleware = new HandlerMiddleware(handler, container ?? new Container());
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
    final container = new Container();
    container.singleton(new ValueObject('y'));
    await expectResponse((ValueObject obj) => obj, '{"property":"y"}', container);
  }
}

class ValueObject {
  final String property;

  ValueObject([this.property]);
}