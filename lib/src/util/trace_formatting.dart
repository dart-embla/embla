import 'package:stack_trace/stack_trace.dart';
import 'dart:math' show max;
import 'dart:core' as core show print;
import 'dart:core' hide print;

traceIdentifier_PJ9ZCKjkkKPFYjgH3jkW(body()) {
  return body();
}

class TraceFormatter {
  final Chain chain;

  TraceFormatter(this.chain);

  factory TraceFormatter.forTrace(StackTrace trace) =>
      new TraceFormatter(new Chain.forTrace(trace));

  Iterable<Frame> get unfilteredFrames {
    final frames = chain.terse.traces
      .expand((t) => t.frames)
      .toList()
      .reversed as Iterable<Frame>;

    if (frames.any(_isTraceIdentifier)) {
      return frames.skipWhile((f) => !_isTraceIdentifier(f)).skip(1);
    }

    return frames;
  }

  List<Frame> get frames {
    final frames = unfilteredFrames
      .where((f) => !f.isCore)
      .where((f) => !f.member.split('.').last.startsWith('_'))
      .where((f) => !f.member.startsWith('_'))
      .where((f) => !new RegExp('<fn>|<async>').hasMatch(f.member)).toList();

    if (frames.last != unfilteredFrames.last)
      frames.add(unfilteredFrames.last);

    return frames;
  }

  int get locationColumnWidth => frames.fold(0, (int previousMax, Frame frame) =>
      max(previousMax, frame.location.length)) + 3;

  String _formatFrame(Frame frame, {bool error: false}) {
    final locationTag = error ? 'red' : 'blue';
    final location = frame.location.padRight(locationColumnWidth).replaceFirstMapped(new RegExp(r'(\d+:\d+)(\s*)$'), (m) => '<$locationTag>${m[1]}</$locationTag>${m[2]}');
    final member = frame.member.replaceAll(new RegExp(r'(?:\.<(?:fn|async)>)+'), ' <gray><italic>anonymous</italic></gray>');
    final memberTag = error ? 'red' : 'green';
    return '<blue>$location</blue><$memberTag>$member</$memberTag>';
  }

  String get formatted {
    return frames.take(frames.length - 1).map(_formatFrame).join('\n')
    + '\n${_formatFrame(frames.last, error: true)}';
  }

  static void print(error, StackTrace trace) {
    final fmt = new TraceFormatter.forTrace(trace);
    core.print('\n<gray><italic>${(' ' * (fmt.locationColumnWidth)) + 'init'}</italic></gray>');
    core.print(fmt.formatted);
    core.print('<red-background><white>\n\n<yellow>    ${new DateTime.now()}</yellow>\n${
        error.toString().split('\n').map((s) => '    $s').join('\n')
    }\n</white></red-background>');
  }

  bool _isTraceIdentifier(Frame frame) {
    return frame.member == 'traceIdentifier_PJ9ZCKjkkKPFYjgH3jkW';
  }
}