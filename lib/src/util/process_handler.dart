import 'dart:async';
import 'package:stack_trace/stack_trace.dart';
import 'dart:io';
import 'trace_formatting.dart';
import 'terminal.dart';

class ProcessHandler {
  final Function init;
  final Function deinit;
  final Terminal terminal = new Terminal();
  final Completer _performShutdown = new Completer();
  final Completer _performTeardown = new Completer();

  ProcessHandler({this.init, this.deinit});

  var initResult;
  StreamSubscription _sigintSub;
  Timer _timer;

  Future run() async {
    runZoned(() {
      return Chain.capture(() async {
        initResult = await init();

        var firstQuit = true;
        _sigintSub = ProcessSignal.SIGINT.watch().listen((_) {
          print('<gray> --> Shutting down...</gray>');
          if (firstQuit) {
            firstQuit = false;
            if (stdout.hasTerminal)
              _timer = new Timer(const Duration(milliseconds: 300), () {
                print(
                    '<blue>Exiting gently...</blue> <italic><gray>Press ^C again to force exit</gray></italic>');
              });
            _performTeardown.complete(null);
            return;
          }
          _performShutdown.complete(null);
        });

        _performTeardown.future.then((_) async {
          await deinit(initResult);
          _performShutdown.complete(null);
        });
      }, onError: TraceFormatter.print);
    }, zoneSpecification: new ZoneSpecification(print: terminal.print));
    await _performShutdown.future;
    _sigintSub?.cancel();
    _timer?.cancel();
  }

  Future interrupt() async {
    if (_performTeardown.isCompleted) return;
    terminal.print(null, null, null, '<green>Reloading...</green>');
    _performTeardown.complete(null);
  }
}
