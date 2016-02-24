import 'dart:io';

const Map<String, _StyleTag> _colors = const {
  'reset': const _StyleTag(0, 0),
  'bold': const _StyleTag(1, 22),
  'dim': const _StyleTag(2, 22),
  'italic': const _StyleTag(3, 23),
  'underline': const _StyleTag(4, 24),
  'inverse': const _StyleTag(7, 27),
  'hidden': const _StyleTag(8, 28),
  'strikethrough': const _StyleTag(9, 29),
  'black': const _StyleTag(30, 39),
  'red': const _StyleTag(31, 39),
  'green': const _StyleTag(32, 39),
  'yellow': const _StyleTag(33, 39),
  'blue': const _StyleTag(34, 39),
  'magenta': const _StyleTag(35, 39),
  'cyan': const _StyleTag(36, 39),
  'white': const _StyleTag(37, 39),
  'gray': const _StyleTag(90, 39),
  'black-background': const _StyleTag(40, 49),
  'red-background': const _StyleTag(41, 49),
  'green-background': const _StyleTag(42, 49),
  'yellow-background': const _StyleTag(43, 49),
  'blue-background': const _StyleTag(44, 49),
  'magenta-background': const _StyleTag(45, 49),
  'cyan-background': const _StyleTag(46, 49),
  'white-background': const _StyleTag(47, 49)
};

class _StyleTag {
  final int _open;
  final int _close;

  const _StyleTag(this._open, this._close);

  String get open => stdout.hasTerminal ? '\u001b[${_open}m' : '';
  String get close => stdout.hasTerminal ? '\u001b[${_close}m' : '';
}

class Stylizer {
  String parse(String input) {
    for (final tagName in _colors.keys) {
      input = input.replaceAll('<$tagName>', _colors[tagName].open);
      input = input.replaceAll('</$tagName>', _colors[tagName].close);
    }
    return input;
  }

  String strip(String input) {
    for (final tagName in _colors.keys) {
      input = input.replaceAll('<$tagName>', '');
      input = input.replaceAll('</$tagName>', '');
    }
    return input;
  }
}
