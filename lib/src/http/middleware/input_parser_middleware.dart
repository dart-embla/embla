import 'dart:async';
import 'dart:convert';
import 'dart:io' show ContentType;

import '../middleware.dart';
import '../request_response.dart';

class Input {
  final dynamic body;

  Input(this.body);

  dynamic toJson() => body;

  String toString() {
    return 'Input($body)';
  }
}

abstract class InputParser {
  Future parse(Stream<List<int>> body, Encoding encoding);
}

class InputParserMiddleware extends Middleware {
  final RawInputParser _raw = new RawInputParser();
  final UrlEncodedInputParser _urlencoded = new UrlEncodedInputParser();
  final MultipartInputParser _multipart = new MultipartInputParser();
  final JsonInputParser _json = new JsonInputParser();

  @override Future<Response> handle(Request request) async {
    context.container = context.container
      .bind(Input, to: await _getInput(request));

    return await super.handle(request.change(body: null));
  }

  ContentType _contentType(Request request) {
    if (!request.headers.containsKey('Content-Type')) {
      return ContentType.TEXT;
    }
    return ContentType.parse(request.headers['Content-Type']);
  }

  Future<Input> _getInput(Request request) async {
    if (['GET', 'HEAD'].contains(request.method)) {
      return new Input(request.url.queryParameters);
    }

    final contentType = _contentType(request);
    final parser = _parser(contentType);

    return new Input(await parser.parse(request.read(), request.encoding ?? UTF8));
  }

  InputParser _parser(ContentType contentType) {
    if (contentType.mimeType == 'application/json') {
      return _json;
    }
    if (contentType.mimeType == 'application/x-www-form-urlencoded') {
      return _urlencoded;
    }
    if (contentType.mimeType == 'application/multipart/form-data') {
      return _multipart;
    }
    return _raw;
  }
}

class JsonInputParser extends InputParser {
  Future parse(Stream<List<int>> body, Encoding encoding) async {
    final asString = await body.map(encoding.decode).join('\n');
    final output = JSON.decode(asString);
    if (output is Map<String, dynamic>) {
      return new Map.unmodifiable(output);
    } else if (output is Iterable) {
      return new List.unmodifiable(output);
    }
    return output;
  }
}

class MultipartInputParser extends InputParser {
  Future parse(Stream<List<int>> body, Encoding encoding) {
    throw new UnimplementedError('Multipart format yet to be implemented');
  }
}

class RawInputParser extends InputParser {
  Future parse(Stream<List<int>> body, Encoding encoding) async {
    return parseString(await body.map(encoding.decode).join('\n'));
  }

  dynamic parseString(String value) {
    if (new RegExp(r'^(?:\d+\.?\d*|\.\d+)$').hasMatch(value)) {
      return num.parse(value);
    }
    if (new RegExp(r'^true$').hasMatch(value)) {
      return true;
    }
    if (new RegExp(r'^false$').hasMatch(value)) {
      return false;
    }
    return value == '' ? null : value;
  }
}

class UrlEncodedInputParser extends InputParser {
  final RawInputParser _raw = new RawInputParser();

  Future<Map<String, String>> parse(Stream<List<int>> body, Encoding encoding) async {
    final value = await body.map(encoding.decode).join('\n');
    return parseQueryString(value);
  }

  // This is absolutely horrendous, but works
  Map<String, String> parseQueryString(String query) {
    _verifyQueryString(query);

    final parts = query.split('&');
    final Iterable<String> rawKeys = parts.map((s) => s.split('=').first);
    final List<String> values = parts.map((s) => s.split('=').last).toList();
    final map = {};
    final rootNamePattern = new RegExp(r'^([^\[]+)(.*)$');
    final contPattern = new RegExp(r'^\[(.*?)\](.*)$');
    dynamic nextValue() {
      return _raw.parseString(Uri.decodeComponent(values.removeAt(0)));
    }
    for (var restOfKey in rawKeys) {
      final rootMatch = rootNamePattern.firstMatch(restOfKey);
      final rootKey = Uri.decodeComponent(rootMatch[1]);
      final rootCont = rootMatch[2];
      if (rootCont == '') {
        map[rootKey] = nextValue();
        continue;
      }
      dynamic target = map;
      dynamic targetKey = rootKey;

      restOfKey = rootCont;

      while (contPattern.hasMatch(restOfKey)) {
        final contMatch = contPattern.firstMatch(restOfKey);
        final keyName = Uri.decodeComponent(contMatch[1]);
        if (keyName == '') {
          target[targetKey] ??= [];
          (target[targetKey] as List).add(null);
          target = target[targetKey];
          targetKey = target.length - 1;
        } else if (new RegExp(r'^\d+$').hasMatch(keyName)) {
          final List targetList = target[targetKey] ??= [];
          final index = int.parse(keyName);
          if (targetList.length == index) {
            targetList.add(null);
          } else {
            targetList[index] ??= null;
          }
          target = targetList;
          targetKey = index;
        } else {
          if (targetKey is String) {
            targetKey = Uri.decodeComponent(targetKey);
          }
          target[targetKey] ??= {};
          (target[targetKey] as Map)[keyName] ??= null;
          target = target[targetKey];
          targetKey = keyName;
        }
        restOfKey = contMatch[2];
      }
      target[targetKey] = nextValue();
    }
    return new Map.unmodifiable(map);
  }

  void _verifyQueryString(String query) {
    final pattern = new RegExp(r'^(?:[^\[]+(?:\[[^\[\]]*\])*(?:\=.*?)?)$');
    if (!pattern.hasMatch(query)) {
      throw new Exception('$query is not a valid query string');
    }
  }
}
