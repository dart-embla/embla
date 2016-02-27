import 'package:quark/unit.dart';
import 'package:embla/http_basic_middleware.dart';
import 'package:embla/src/http/pipeline.dart';
import 'middleware_call.dart';
import 'package:embla/src/http/context.dart';
export 'package:quark/init.dart';

class ConditionalMiddlewareTest extends UnitTest {
  @before
  setUp() {
    setUpContextForTesting();
  }

  @test
  itWorks() async {
    final middleware = new ConditionalMiddleware(() => true, pipe(() => 'x'));
    await expectMiddlewareResponseBody(middleware, 'x');
  }

  @test
  itPassesOnIfConditionFails() async {
    final middleware = new ConditionalMiddleware(() => false, pipe(() => 'x'));
    expect(middlewareCall(middleware), throwsA(new isInstanceOf<NoResponseFromPipelineException>()));
  }
}
