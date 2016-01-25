import 'package:quark/unit.dart';
import 'package:embla/src/http/route_expander.dart';
export 'package:quark/init.dart';

class RouteExpanderTest extends UnitTest {
  final RouteExpander expander = new RouteExpander();

  void expands(String input, String output) {
    expect(expander.expand(input), output);
  }

  void prefixes(String pattern, String input, String output) {
    expect(expander.prefix(pattern, input), output);
  }

  @test
  itTurnsAStringIntoARegex() {
    expands('foo', r'^foo$');
  }

  @test
  itNormalizesSlashes() {
    expands('/', r'^$');
    expands('/foo', r'^foo$');
    expands('/foo/', r'^foo$');
    expands('/foo//', r'^foo$');
    expands('/foo//bar', r'^foo\/bar$');
    expands('foo/bar//', r'^foo\/bar$');
  }

  @test
  itExpandsWildcards() {
    expands(':foo', r'^([^/]+)$');
    expands('foo/:bar', r'^foo\/([^/]+)$');
  }

  @test
  itExpandsAStar() {
    expands('foo/*', r'^foo\/?(.*)$');
  }

  @test
  itDeterminesThePrefixOfAPathExpression() {
    prefixes('/', '', '');
    prefixes('/foo', 'foo', 'foo');
    prefixes('/foo/:wildcard', 'foo/bar', 'foo/bar');
    prefixes('/foo/:wildcard/*', 'foo/bar/more/things', 'foo/bar');
  }

  @test
  itThrowsWhenThePathDoesntMatch() {
    expect(() => expander.prefix('/', 'foo'), throws);
  }

  @test
  itParsesWildcards() {
    expect(expander.parseWildcards('foo/:bar', 'foo/x'), {'bar': 'x'});
  }
}