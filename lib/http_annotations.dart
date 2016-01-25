import 'http.dart';

class RouteHandler {
  final Iterable<String> methods;
  final String path;

  const RouteHandler(this.methods, this.path);

  Middleware toHandler(Function method, [String fallbackPath]) {
    return Route.match(methods, path ?? fallbackPath, handler(method));
  }
}

class Get extends RouteHandler {
  const Get([String path]) : super(const ['GET', 'HEAD'], path);
}

class Post extends RouteHandler {
  const Post([String path]) : super(const ['POST'], path);
}

class Put extends RouteHandler {
  const Put([String path]) : super(const ['PUT'], path);
}

class Patch extends RouteHandler {
  const Patch([String path]) : super(const ['PATCH'], path);
}

class Update extends RouteHandler {
  const Update([String path]) : super(const ['UPDATE'], path);
}

class Delete extends RouteHandler {
  const Delete([String path]) : super(const ['DELETE'], path);
}

class Options extends RouteHandler {
  const Options([String path]) : super(const ['OPTIONS'], path);
}

class All extends RouteHandler {
  const All([String path])
      : super(const ['GET', 'HEAD', 'OPTIONS', 'POST', 'PUT', 'PATCH', 'UPDATE', 'DELETE'], path);
}
