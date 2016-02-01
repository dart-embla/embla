import 'package:quark/unit.dart';
import 'package:embla/src/http/response_maker.dart';
import 'dart:io';
import 'dart:async';
export 'package:quark/init.dart';

class ResponseMakerTest extends UnitTest {
  final ResponseMaker responseMaker = new ResponseMaker();

  void parses(input, body, ContentType contentType) {
    final r = responseMaker.parse(input);

    expect(r.body, body);
    expect(r.contentType, contentType);
    expect(r, new isInstanceOf<DataResponse>());
  }

  @test
  itMakesDataResponseObjects() {
    expect(responseMaker.parse(null), new isInstanceOf<DataResponse>());
  }

  @test
  itTurnsSimpleDataIntoAnHtmlResponse() {
    parses(null, '', ContentType.HTML);
    parses('', '', ContentType.HTML);
    parses('x', 'x', ContentType.HTML);
    parses(1, '1', ContentType.HTML);
    parses(1.2, '1.2', ContentType.HTML);
    parses(true, 'true', ContentType.HTML);
  }

  @test
  itTurnsAListIntoJson() {
    parses([], [], ContentType.JSON);
    parses([null], [null], ContentType.JSON);
    parses([null, 'x'], [null, 'x'], ContentType.JSON);
  }

  @test
  itTurnsAMapIntoJson() {
    parses({}, {}, ContentType.JSON);
    parses({'k': 'v'}, {'k': 'v'}, ContentType.JSON);
  }

  @test
  itTurnsAClassIntoJson() {
    parses(new MyClass('x'), {'property': 'x'}, ContentType.JSON);
    parses(
        new MyNestingClass(new MyClass('x')),
        {'nested': {'property': 'x'}},
        ContentType.JSON
    );
  }

  @test
  itTurnsAStreamOfObjectsIntoJsonStream() async {
    final r = responseMaker.parse(new Stream<Object>.fromIterable([new MyClass('x'), 2, 3]));

    expect(r, new isInstanceOf<DataResponse>());
    expect(r.contentType, ContentType.JSON);
    expect(await r.jsonStream(r.body).toList(), ['[', '{"property":"x"}', ',', '2', ',', '3', ']']);
  }

  @test
  itTurnsAStreamOfStringsIntoHtmlOutputStream() async {
    final r = responseMaker.parse(new Stream<String>.fromIterable(['a', 'b', 'c']));

    expect(r, new isInstanceOf<DataResponse>());
    expect(r.contentType, ContentType.HTML);
    expect(await r.body.toList(), ['a', 'b', 'c']);
  }
}

class MyClass {
  final String property;

  MyClass(this.property);
}

class MyNestingClass {
  final MyClass nested;

  MyNestingClass(this.nested);
}
