import 'package:quark/unit.dart';
export 'package:quark/init.dart';
import 'package:embla/http.dart';
import 'package:embla/http_annotations.dart';
import 'dart:async';

class PipelineTest extends UnitTest {
  Request request(String path, String method) => new Request(method, new Uri.http('localhost', path));

  Future expectResponse(String method, String path, PipelineFactory pipeline, String body) async {
    expect(
        await (await pipeline()(request(path, method))).readAsString(),
        await new Response.ok(body).readAsString()
    );
  }

  Future expectThrows(String method, String path, PipelineFactory pipeline, Matcher matcher) async {
    expect(pipeline()(request(path, method)), throwsA(matcher));
  }

  @test
  itCreatesAnHttpPipeline() async {
    await expectResponse('GET', '/', pipe(MyMiddleware), 'response');
  }

  @test
  itThrowsA404WithoutMiddleware() async {
    await expectThrows('GET', '/', pipe(), new isInstanceOf<NoResponseFromPipelineException>());
  }

  @test
  itPipesThroughMultipleMiddleware() async {
    await expectResponse('GET', '/', pipe(
        MyPassMiddleware,
        MyPassMiddleware,
        MyPassMiddleware,
        MyMiddleware
    ), 'response');
  }

  @test
  aRouteIsMiddleware() async {
    final pipeline = pipe(
        Route.get('/', MyMiddleware)
    );

    await expectResponse('GET', '/', pipeline, 'response');

    await expectThrows('GET', 'endpoint', pipeline,
        new isInstanceOf<NoResponseFromPipelineException>());

    await expectThrows('POST', '/', pipeline,
        new isInstanceOf<NoResponseFromPipelineException>());
  }

  @test
  aHandlerIsMiddleware() async {
    await expectResponse('GET', '/',
        pipe(
            handler(() => 'x')
        ),
        'x'
    );
  }

  @test
  isHandlesWildcards() async {
    await expectResponse('GET', '/foo/a/b',
        pipe(
            Route.get('foo/:x/:y',
              ({String x, String y}) => x + y
            )
        ),
        'ab'
    );
  }

  @test
  aControllerIsMiddleware() async {
    await expectResponse('GET', '/',
        pipe(MyController),
        'index'
    );

    await expectResponse('GET', 'x',
        pipe(MyController),
        '{"property":"x"}'
    );
  }
}

class MyMiddleware extends Middleware {
  @override Future<Response> handle(Request request) async {
    return ok('response');
  }
}

class MyPassMiddleware extends Middleware {
}

class MyController extends Controller {
  @Get('/')
  index() {
    return 'index';
  }

  @Get(null)
  x() {
    return new MyDataClass('x');
  }
}

class MyDataClass {
  final String property;

  MyDataClass(this.property);
}
