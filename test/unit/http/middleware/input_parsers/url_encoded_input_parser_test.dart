import 'package:quark/unit.dart';
import 'package:embla/src/http/middleware/input_parser_middleware.dart';
export 'package:quark/init.dart';
import 'input_parser_expectation.dart';

class UrlEncodedInputParserTest extends UnitTest {
  @test
  itWorks() async {
    final parser = new UrlEncodedInputParser();
    await expectParserOutput(parser, 'y=x', {'y': 'x'});
    await expectParserOutput(parser, 'y=x&a=b', {'y': 'x', 'a': 'b'});
    await expectParserOutput(parser, 'y[]=1&y[]=2', {'y': [1, 2]});
    await expectParserOutput(parser, 'y[0][key]=1&y[0][key2]=2', {'y': [{'key': 1, 'key2': 2}]});
    await expectParserOutput(parser, 'y[0][key][]=1&y[0][key][]=2', {'y': [{'key': [1, 2]}]});
    await expectParserOutput(parser, 'urlencoded%20key=urlencoded%20value', {'urlencoded key': 'urlencoded value'});
    await expectParserOutput(parser, 'y%5B%5D[0][key%20][]=1&y%5B%5D[0][key%20][]=2', {'y[]': [{'key ': [1, 2]}]});
  }
}
