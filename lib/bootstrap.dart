import 'dart:mirrors';
import 'dart:io';
import 'application.dart';
import 'src/util/process_handler.dart';
import 'dart:isolate';
import 'dart:async';

main(List<String> arguments, SendPort sendExitCommandPort) async {
  final instancesCount = _instancesCount(arguments.join(' '));

  final instances = new List.generate(instancesCount, (i) => i + 1)
    .map((i) => new EmblaInstance(isolateNumber: i, totalIsolateCount: instancesCount))
    .toList();

  final exitCommandPort = new ReceivePort();

  final processHandler = new ProcessHandler(
    init: () {
      print('<gray><italic>Press Ctrl+C to exit</italic></gray>');
      return Future.wait(instances.map((i) => i.init()));
    },
    deinit: (_) {
      print('<gray> --> Shutting down...</gray>');
      return Future.wait(instances.map((i) => i.deinit()));
    }
  );

  if (sendExitCommandPort != null) {
    sendExitCommandPort.send(exitCommandPort.sendPort);

    exitCommandPort.listen((_) {
      processHandler.interrupt();
    });
  }

  await processHandler.run();

  exitCommandPort.close();
}

final _instancesPattern = new RegExp(r'(?:--isolates|-i)[\s=](\d+)');

int _instancesCount(String argv) {
  if (!_instancesPattern.hasMatch(argv)) {
    return 1;
  }
  return int.parse(_instancesPattern.firstMatch(argv)[1]);
}

class EmblaInstance {
  final willReceiveInterruptPort = new ReceivePort();
  final onExit = new ReceivePort();
  final onPrint = new ReceivePort();
  SendPort interruptPort;

  final int isolateNumber;
  final int totalIsolateCount;

  EmblaInstance({this.isolateNumber, this.totalIsolateCount});

  Future init() async {
    onPrint.listen(print);
    Isolate.spawn(emblaMain, {
      #interruptPort: willReceiveInterruptPort.sendPort,
      #printPort: onPrint.sendPort,
      #isolateNumber: isolateNumber,
      #totalIsolateCount: totalIsolateCount
    }, onExit: onExit.sendPort);
    interruptPort = await willReceiveInterruptPort.first;
    willReceiveInterruptPort.close();
  }

  Future deinit() async {
    if (interruptPort == null) {
      return;
    }
    interruptPort.send(null);
    await onExit.first;
    onExit.close();
    onPrint.close();
  }
}

emblaMain(Map<Symbol, dynamic> args) async {
  final SendPort sendExitCommandPort = args[#interruptPort];
  final SendPort printPort = args[#printPort];
  final int isolateNumber = args[#isolateNumber];
  final int totalIsolateCount = args[#totalIsolateCount];
  final exitCommandPort = new ReceivePort();

  await runZoned(() async {
    final app = await Application.boot(
        _findConfig()
    );

    exitCommandPort.listen((_) {
      exitCommandPort.close();
      app.exit();
    });

    sendExitCommandPort.send(exitCommandPort.sendPort);
  }, zoneSpecification: new ZoneSpecification(
    print: (_, __, ___, line) => printPort.send(line)
  ), zoneValues: {
    #embla.isolates: new Isolates(
      count: totalIsolateCount,
      current: isolateNumber
    ),
  });
}

List<Bootstrapper> _findConfig() {
  final library = currentMirrorSystem().libraries[Platform.script];
  if (library == null) {
    throw new Exception('The script entry point is not a library. For more information, visit https://embla.io/docs');
  }

  final emblaMethod = library.declarations[#embla];
  if (emblaMethod == null) {
    throw new Exception('Found no [embla] getter in ${Platform.script}. For more information, visit https://embla.io/docs');
  }

  final bootstrappers = library
      .getField(#embla)
      .reflectee;

  if (bootstrappers is! List<Bootstrapper>) {
    throw new Exception('The [embla] getter should return a [List<Bootstrapper>]. For more information, visit https://embla.io/docs');
  }

  return bootstrappers as List<Bootstrapper>;
}
