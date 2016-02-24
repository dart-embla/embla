import 'package:quark/unit.dart';
export 'package:quark/init.dart';
import 'package:embla/src/http/middleware/error_handler_middleware.dart';
import 'middleware_call.dart';
import 'package:stack_trace/stack_trace.dart';

class ErrorHandlerMiddlewareTest extends UnitTest {
  @test
  itDoesNothingWithoutRegisteringHandlers() async {
    final middleware = new ErrorHandlerMiddleware();

    final response = await middlewareCall(middleware);

    expect(response.statusCode, 500);
  }

  @test
  itCanRegisterHandlersForTypes() async {
    final middleware = ErrorHandlerMiddleware
      .on(String, () => "response");

    final response = await middlewareCall(middleware, null, (r) => throw "");

    expect(await response.readAsString(), 'response');
    expect(response.statusCode, 200);
  }

  @test
  itInjectsErrorStackAndChain() async {
    final middleware = ErrorHandlerMiddleware
      .on(String, (String s, StackTrace t, Chain c) => s);

    final response = await middlewareCall(middleware, null, (r) => throw "message");

    expect(await response.readAsString(), 'message');
    expect(response.statusCode, 200);
  }

  @test
  itWarnsWhenALessSpecificHandlerIsAddedLater() async {
    ErrorHandlerMiddleware
      .on(SuperClass, () => null)
      .on(SubClass, () => null);

    expect(() {
      ErrorHandlerMiddleware
        .on(SubClass, () => null)
        .on(SuperClass, () => null);
    }, throwsA(new isInstanceOf<BadErrorHandlerOrderException>()));
  }
}

abstract class SuperClass {}

class SubClass extends SuperClass {}
