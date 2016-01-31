import 'dart:async';
import 'package:embla/src/http/middleware/input_parser_middleware.dart';
import 'package:test/test.dart';
import 'dart:convert';

Future expectParserOutput(InputParser parser, String input, dynamic expectedOutput) async {
  expect(await parser.parse(_stringToCharStream(input), UTF8), expectedOutput);
}

Stream<List<int>> _stringToCharStream(String input) {
  final Stream<String> lines = new Stream<String>.fromIterable(input.split('\n'));
  return lines.map/*<List<int>>*/(UTF8.encode) as Stream<List<int>>;
}

