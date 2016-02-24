import 'package:quark/unit.dart';
import 'package:embla/src/http/middleware/input_parser_middleware.dart';
export 'package:quark/init.dart';
import 'input_parser_expectation.dart';

class JsonInputParserTest extends UnitTest {
  @test
  itWorks() async {
    final parser = new JsonInputParser();
    await expectParserOutput(parser, '"x"', 'x');
    await expectParserOutput(parser, '3', 3);
    await expectParserOutput(parser, '3.2', 3.2);
    await expectParserOutput(parser, '0.2', 0.2);
    await expectParserOutput(parser, 'true', true);
    await expectParserOutput(parser, '{"x":"y"}', {'x': 'y'});
    await expectParserOutput(parser, '["x","y"]', ['x', 'y']);
  }
}
