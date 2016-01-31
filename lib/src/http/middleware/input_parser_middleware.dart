import 'dart:async';
import 'dart:convert';
import 'dart:io' show ContentType;

import '../middleware.dart';
import '../helpers.dart';
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
    final withInput = applyInjections({
      Input: await _getInput(request)
    });

    return await withInput(super.handle)(request.change(body: null));
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
    final value = await body.map(encoding.decode).join('\n');
    if (new RegExp(r'^(?:\d+\.?\d*|\.\d+)$').hasMatch(value)) {
      return num.parse(value);
    }
    return value == '' ? null : value;
  }
}

class UrlEncodedInputParser extends InputParser {
  Future<Map<String, String>> parse(Stream<List<int>> body, Encoding encoding) async {
    final value = await body.map(encoding.decode).join('\n');
    return parseQueryString(value);
  }

  Map<String, String> parseQueryString(String query) {
    final parts = query.split('&');
    return new Map.unmodifiable(new Map.fromIterables(
        parts.map((s) => s.split('=').toList()[0].toString()) as Iterable<String>,
        parts.map((s) => s.split('=').toList()[1])
    ));
  }
}

