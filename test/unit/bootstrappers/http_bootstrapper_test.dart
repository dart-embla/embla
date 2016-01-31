import 'package:quark/unit.dart';
import 'package:quark/test_double.dart';
import 'package:embla/http.dart';
import 'dart:io';
import 'dart:async';
export 'package:quark/init.dart';

class HttpBootstrapperTest extends UnitTest {
  HttpBootstrapper bootstrapper(HttpServerDouble server, PipelineFactory pipeline) {
    return new HttpBootstrapper.internal((host, int port) async => server, 'localhost', 1337, pipeline)..attach();
  }

  dynamic silent(body()) {
    return runZoned(body, zoneSpecification: new ZoneSpecification(print: (a, b, c, d) => null));
  }

  @test
  itWorks() async {
    final server = new HttpServerDouble();

    final boot = bootstrapper(server, pipe());

    await boot.bindings();
  }

  @test
  itStartsAServer() async {
    final server = new HttpServerDouble();

    final boot = bootstrapper(server, pipe());

    when(server.port).thenReturn(1337);
    when(server.address).thenReturn(new InternetAddress('127.0.0.1'));

    await boot.bindings();
    await silent(() async => await boot.start(server));

    verify(server.listen(null)).wasCalled();
  }

  @test
  itHandlesRequests() async {
    final server = new HttpServerDouble();
    final PipelineFactory pipelineFactory = pipe(
        () => 'response'
    );
    final boot = bootstrapper(server, pipelineFactory);
    final Pipeline pipeline = pipelineFactory();

    final request = new Request('GET', new Uri.http('localhost', '/'));
    final response = await boot.handleRequest(request, pipeline);
    expect(await response.readAsString(), 'response');
  }
}

class HttpServerDouble extends TestDouble implements HttpServer {}
