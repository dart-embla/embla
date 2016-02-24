import 'package:quark/unit.dart';
import 'package:embla/src/http/middleware/input_parser_middleware.dart';
export 'package:quark/init.dart';
import 'input_parser_expectation.dart';

class RawInputParserTest extends UnitTest {
  @test
  itWorks() async {
    final parser = new RawInputParser();
    await expectParserOutput(parser, 'x', 'x');
    await expectParserOutput(parser, '3', 3);
    await expectParserOutput(parser, '3.2', 3.2);
    await expectParserOutput(parser, '.2', 0.2);
    await expectParserOutput(parser, 'true', true);
  }
}
