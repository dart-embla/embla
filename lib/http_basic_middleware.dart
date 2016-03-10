import 'dart:io';

import 'http.dart';
import 'src/http/middleware/input_parser_middleware.dart';
import 'src/http/middleware/logger_middleware.dart';
import 'src/http/middleware/remove_trailing_slash_middleware.dart';
import 'src/http/middleware/pub_middleware.dart';

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
