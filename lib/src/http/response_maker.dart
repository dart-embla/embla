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

    if (anything is Stream<String>) {
      return new DataResponse(anything, ContentType.HTML);
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
       members.map((m) => m.simpleName).map(MirrorSystem.getName),
       members.map((m) => _serialize(mirror.getField(m.simpleName).reflectee))
    ));
  }
}

class DataResponse {
  final body;
  final ContentType contentType;

  DataResponse(this.body, this.contentType);

  Response status(int statusCode) {
    final outputBody = () {
      if (body is Stream<String>) {
        return body.map/*<List<int>>*/(UTF8.encode);
      } else if (body is Stream<Object>) {
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
    yield '[';
    bool isFirst = true;
    await for (final item in stream) {
      if (isFirst) {
        isFirst = false;
      } else {
        yield ',';
      }
      yield JSON.encode(item);
    }
    yield ']';
  }
}