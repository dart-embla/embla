import 'dart:convert';
import 'dart:mirrors';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'dart:async';

class ResponseMaker {
  DataResponse parse(anything) {
    if (anything == null ||
        anything is String ||
        anything is bool ||
        anything is num) {
      return new DataResponse((anything ?? '').toString(), ContentType.HTML);
    }

    if (anything is Stream) {
      final typeArgument = reflect(anything).type.typeArguments[0];
      final json = typeArgument.reflectedType == dynamic
                || !typeArgument.isSubtypeOf(reflectType(String));
      if (json) {
        return new DataResponse(_serialize(anything), ContentType.JSON);
      }
      return new DataResponse(_serialize(anything), ContentType.HTML);
    }

    return new DataResponse(_serialize(anything), ContentType.JSON);
  }

  _serialize(anything) {
    if (anything == null ||
        anything is String ||
        anything is bool ||
        anything is num) {
      return anything;
    }

    if (anything is DateTime) {
      return anything.toUtc().toIso8601String();
    }

    if (anything is Stream<Object>) {
      return anything.map(_serialize);
    }

    if (anything is Iterable) {
      return new List.unmodifiable(anything.toList().map(_serialize));
    }

    if (anything is Map) {
      return new Map.unmodifiable(
          new Map.fromIterables(
              anything.keys.map((k) => '$k'),
              anything.values.map(_serialize)
          )
      );
    }

    final mirror = reflect(anything);
    if (mirror.type.instanceMembers.keys.contains(#toJson)) {
      return _serialize(mirror.reflectee.toJson());
    }

    final members = mirror.type.instanceMembers.values
        .where((m) => m.owner is! ClassMirror || (m.owner as ClassMirror).reflectedType != Object)
        .where((m) => m.isGetter)
        .where((m) => !m.isPrivate);
    return new Map.unmodifiable(new Map.fromIterables(
       members.map((m) => m.simpleName).map(MirrorSystem.getName).map(_toSnakeCase),
       members.map((m) => _serialize(mirror.getField(m.simpleName).reflectee))
    ));
  }

  String _toSnakeCase(String input) {
    return input
      .split('_')
      .expand((p) => p.split(new RegExp(r'(?=[A-Z])')))
      .map((s) => s.toLowerCase())
      .join('_');
  }
}

class DataResponse {
  final body;
  final ContentType contentType;

  DataResponse(this.body, this.contentType);

  Response status(int statusCode) {
    final outputBody = () {
      if (body is Stream) {
        return jsonStream(body).map/*<List<int>>*/(UTF8.encode);
      } else if (body is String) {
        return body;
      } else {
        return JSON.encode(body);
      }
    }();
    return new Response(statusCode, body: outputBody, headers: {
      'Content-Type': contentType.toString()
    });
  }

  Stream<String> jsonStream(Stream<Object> stream) async* {
    bool jsonTarget = contentType == ContentType.JSON;
    bool first = true;
    if (jsonTarget) yield '[';
    await for (final item in stream) {
      if (first) {
        first = false;
      } else {
        if (jsonTarget) yield ',';
      }
      if (jsonTarget) yield JSON.encode(item);
      else yield item;
    }
    if (jsonTarget) yield ']';
  }
}
