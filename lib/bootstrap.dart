import 'dart:mirrors';
import 'dart:io';
import 'application.dart';
import 'src/util/process_handler.dart';
import 'dart:isolate';

main(List<String> arguments, SendPort sendExitCommandPort) async {
  final exitCommandPort = new ReceivePort();

  final processHandler = new ProcessHandler(
      init: () {
        print('<gray><italic>Press Ctrl+C to exit</italic></gray>');
        return Application.boot(_findConfig());
      },
      deinit: (Application app) {
        return app.exit();
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
