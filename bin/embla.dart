#!/usr/bin/env dart

import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:watcher/watcher.dart';

main(List<String> args) async {
  final arguments = args.toList();
  if (arguments.length < 1) return print('Usage: embla start');
  final command = arguments.removeAt(0);
  if (command != 'start') return print('''Usage: embla start <options>

Options:
  [--isolates | -i] <int>    The number of instances to run (defaults to 1)
''');

  final filePath = '${Directory.current.path}/bin/server.dart';
  final fileUri = new Uri.file(filePath);
  bool willRestart = true;
  SendPort restartPort;
  StreamController changeBroadcast = new StreamController.broadcast();

  final watcher = new Watcher(Directory.current.path).events.listen((event) {
    if (!event.path.endsWith('.dart')) return;

    changeBroadcast.add(event);
    willRestart = true;
    restartPort?.send(null);
  });

  while (willRestart) {
    willRestart = false;
    final exitPort = new ReceivePort();
    final errorPort = new ReceivePort();
    final receiveExitCommandPort = new ReceivePort();
    await Isolate.spawnUri(
        fileUri,
        arguments,
        receiveExitCommandPort.sendPort,
        onExit: exitPort.sendPort,
        onError: errorPort.sendPort,
        errorsAreFatal: false,
        automaticPackageResolution: true
    );

    restartPort = await receiveExitCommandPort.first
        .timeout(const Duration(seconds: 10));

    final process = new Completer<int>();
    errorPort.listen((List l) async {
      print(l[0]);
      print('Listening for changes...');
      await changeBroadcast.stream.first;
      if (!process.isCompleted) process.complete(0);
    });
    exitPort.listen((_) {
      if (!process.isCompleted) process.complete(0);
    });

    exitCode = await process.future;
    exitPort.close();
    errorPort.close();
    receiveExitCommandPort.close();
  }

  await watcher.cancel();
}
