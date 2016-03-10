import 'dart:async';
import 'dart:io';

import '../../../http.dart';
import 'forwarder_middleware.dart';
import 'static_files_middleware.dart';

/// Enables integration with pub workflow. If the application is in development mode,
/// requests will be forwarded to `pub serve`. If not in dev mode, *build/web* will be
/// used for static assets.
class PubMiddleware extends Middleware {
  final bool developmentMode;
  final int servePort;
  final String buildDir;

  Middleware __static;
  Middleware __forward;

  Middleware get _static => __static
    ??= new StaticFilesMiddleware(fileSystemPath: '$buildDir/web', defaultDocument: 'index.html');
  Middleware get _forward => __forward
    ??= new ForwarderMiddleware(to: 'http://localhost:$servePort');

  /// [developmentMode] will determine whether or not the app is in dev mode. If omitted,
  /// a check for an environment variable called `APP_ENV` having value 'development' will
  /// be the default check.
  ///
  /// [servePort] and [buildDir] can be used if the default serve and build options are not
  /// used with pub.
  PubMiddleware({
    bool developmentMode,
    this.servePort: 8080,
    this.buildDir: 'build'
  }) : developmentMode = developmentMode ?? Platform.environment['APP_ENV'] == 'development';

  @override Future<Response> handle(Request request) async {
    final response = developmentMode
      ? await _forward.handle(request)
      : await _static.handle(request);

    if (response.statusCode == 404) {
      abortNotFound(await response.readAsString());
    }

    return response;
  }
}
