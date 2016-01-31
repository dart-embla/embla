import 'package:quark/unit.dart';
import 'package:embla/http_basic_middleware.dart';
import 'package:embla/src/http/pipeline.dart';
import 'middleware_call.dart';
export 'package:quark/init.dart';

class ConditionalMiddlewareTest extends UnitTest {
  @test
  itWorks() async {
    final middleware = new ConditionalMiddleware((_) => true, pipe(() => 'x'));
    await expectMiddlewareResponseBody(middleware, 'x');
  }

  @test
  itPassesOnIfConditionFails() async {
    final middleware = new ConditionalMiddleware((_) => false, pipe(() => 'x'));
    expect(middlewareCall(middleware), throwsA(new isInstanceOf<NoResponseFromPipelineException>()));
  }
}