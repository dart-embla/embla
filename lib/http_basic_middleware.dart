import 'dart:io';

import 'http.dart';
import 'src/http/middleware/input_parser_middleware.dart';
import 'src/http/middleware/logger_middleware.dart';
import 'src/http/middleware/remove_trailing_slash_middleware.dart';
import 'src/http/middleware/forwarder_middleware.dart';
import 'src/http/middleware/static_files_middleware.dart';
import 'src/http/middleware/conditional_middleware.dart';

export 'src/http/middleware/conditional_middleware.dart';
export 'src/http/middleware/error_handler_middleware.dart';
export 'src/http/middleware/forwarder_middleware.dart';
export 'src/http/middleware/input_parser_middleware.dart';
export 'src/http/middleware/logger_middleware.dart';
export 'src/http/middleware/remove_trailing_slash_middleware.dart';
export 'src/http/middleware/static_files_middleware.dart';

/// Reasonable basic middleware that should probably always be used.
Iterable<Type> get basicMiddleware => [
  RemoveTrailingSlashMiddleware,
  LoggerMiddleware,
  InputParserMiddleware,
];

/// Enables integration with pub workflow. If the application is in development mode,
/// requests will be forwarded to `pub serve`. If not in dev mode, *build/web* will be
/// used for static assets.
///
/// [developmentMode] will determine whether or not the app is in dev mode. If omitted,
/// a check for an environment variable called `APP_ENV` having value 'development' will
/// be the default check.
///
/// [servePort] and [buildDir] can be used if the default serve and build options are
/// used with pub.
Iterable<Middleware> staticPubBuild({
  bool developmentMode,
  int servePort: 8080,
  String buildDir: 'build'
}) {
  final devMode = developmentMode ?? Platform.environment['APP_ENV'] == 'development';
  return [
    pipeIf(() => devMode, new ForwarderMiddleware(to: 'http://localhost:$servePort')),
    new StaticFilesMiddleware(fileSystemPath: '$buildDir/web', defaultDocument: 'index.html')
  ];
}
