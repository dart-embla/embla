import 'dart:async';

import '../middleware.dart';
import '../request_response.dart';
import '../pipeline.dart';

class LoggerMiddleware extends Middleware {
  @override Future<Response> handle(Request request) async {
    final beforeTime = new DateTime.now();
    duration() => beforeTime.difference(new DateTime.now());
    try {
      final response = await super.handle(request);
      final controller = new StreamController<List<int>>();
      var errored = false;
      response.read().listen(controller.add, onDone: () {
        controller.close();
        if (errored) return;
        _log(request, response.statusCode, duration());
      }, onError: (e, s) {
        _log(request, response.statusCode, duration(), failed: true);
        errored = true;
        controller.addError(e, s);
      });
      return response.change(body: controller.stream);
    } on NoResponseFromPipelineException {
      _log(request, 404, duration());
      rethrow;
    } on HttpException catch(e) {
      _log(request, e.statusCode, duration());
      rethrow;
    } catch(e) {
      _log(request, 500, duration());
      rethrow;
    }
  }

  void _log(Request request, int statusCode, Duration time, {bool failed: false}) {
    final url = request.handlerPath + request.url.path;
    final statusColor = () {
      if (statusCode >= 200 && statusCode < 300) {
        return 'green';
      }
      if (statusCode >= 300 && statusCode < 400) {
        return 'magenta';
      }
      if (statusCode >= 400 && statusCode < 500) {
        return 'yellow';
      }
      if (statusCode >= 500 && statusCode < 600) {
        return 'red';
      }
      return 'black';
    }();

    final timeInMilliseconds = time.abs().inMicroseconds / 1000;
    final timeColor = () {
      if (timeInMilliseconds > 800) {
        return 'red';
      }
      if (timeInMilliseconds > 400) {
        return 'yellow';
      }
      return 'gray';
    }();

    final suffix = failed ? '<red>THREW AFTER HEADERS WAS SENT</red>' : '';

    print('<gray><italic>${new DateTime.now()}</italic></gray> '
        '<$statusColor>$statusCode</$statusColor> '
        '<blue>${request.method}</blue> '
        '$url '
        '<$timeColor><italic>$timeInMilliseconds ms</italic></$timeColor> '
        '$suffix');
  }
}
