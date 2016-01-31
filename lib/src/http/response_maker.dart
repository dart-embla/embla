import 'dart:convert';
import 'dart:mirrors';
import 'dart:io';
import 'package:shelf/shelf.dart';

class ResponseMaker {
  DataResponse parse(anything) {
    if (anything == null ||
        anything is String ||
        anything is bool ||
        anything is num) {
      return new DataResponse((anything ?? '').toString(), ContentType.HTML);
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
       members.map((m) => m.simpleName).map(MirrorSystem.getName),
       members.map((m) => _serialize(mirror.getField(m.simpleName).reflectee))
    ));
  }
}

class DataResponse {
  final body;
  final ContentType contentType;

  DataResponse(this.body, this.contentType);

  String get stringBody {
    if (body is String) return body;
    return JSON.encode(body);
  }

  Response status(int statusCode) {
    return new Response(statusCode, body: stringBody, headers: {
      'Content-Type': contentType.toString()
    });
  }
}