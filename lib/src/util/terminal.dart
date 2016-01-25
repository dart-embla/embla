import 'dart:async';
import 'dart:io';
import 'stylizer.dart';

class Terminal {
  final Stylizer stylizer = new Stylizer();

  void print(Zone self, ZoneDelegate parent, Zone zone, String line) {
    stdout.writeln(stylizer.parse(line));
  }
}
