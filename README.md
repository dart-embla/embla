# Embla

Embla is a powerful but simple server side application framework for Dart.

## Overview
Here's an example of a super simple Embla app.

```dart
export 'package:embla/bootstrap.dart';
import 'package:embla/http.dart';

get embla => [
  new HttpBootstrapper(
    pipeline: pipe(() => 'Hello world!')
  )
];
```

This application starts a server, and responds with "Hello world!" on every request. Looks weird?
Let's figure out what's going on.

## Bootstrapping
Instead of the good old `main` function, Embla requires a getter called `embla` in the main entry
point script. The actual main function will be provided by `bootstrap.dart`.

```dart
export 'package:embla/bootstrap.dart';

get embla => [];
```

If we were to run the above script, we would get an empty Dart process that did nothing, and
would close on Ctrl+C.

To hook into the application, we can add `Bootstrappers` to the `embla` function. `HttpBootstrapper`
comes out of the box if we just import `'package:embla/http.dart'`. Each bootstrapper should be
instantiated in the `embla` function, and any configuration needed is passed through the constructor.

## HTTP Pipeline
It just so happens the `HttpBootstrapper` takes a named `pipeline` parameter, that represents the
request/response pipeline for the server.

To create a pipeline, we use the `pipe` helper provided by `embla/http.dart`. A pipeline consists
of a series of Middleware. Embla wraps `Shelf` for this.

```dart
import 'dart:async';

export 'package:embla/bootstrap.dart';
import 'package:embla/http.dart';

get embla => [
  new HttpBootstrapper(
    pipeline: pipe(
      MyMiddleware
    )
  )
];

class MyMiddleware extends Middleware {
  Future<Response> handle(Request request) {
    // Pass along to the next middleware
    return super.handle(request);
  }
}
```

The pipe allows for different formats for Middleware. You can pass in a Shelf Middleware
directly, or the `Type` of a middleware class. It also supports passing in a `Function`,
which will be converted to a route handler.

## Routing
Routes are nothing more than conditional paths in the pipeline. Here's an example:

```dart
pipeline: pipe(

  MiddlewareForAllRoutes,

  Route.get('/', () => 'Hello world'),

  Route.all('subroutes/*',
    MiddlewareForAllRoutesInSubroutes,

    Route.get('', () => 'Will be reached by GET /subroutes'),

    Route.put('action', () => 'Will be reached by PUT /subroutes/action'),

    Route.get('another',
      SpecialMiddlewareForThisRoute,
      () => 'Will be reached by PUT /subroutes/another'
    ),

    Route.get('deeper/:wildcard',
      ({String wildcard}) => 'GET /subroutes/deeper/$wildcard'
    )
  ),

  () => 'This will be reached by request not matching the routes above'
)
```

## Controller
In Embla, controllers are also middleware. They are collections of routes, after all.
The controllers use annotations to declare routes.

```dart
export 'package:embla/bootstrap.dart';
import 'package:embla/http.dart';
import 'package:embla/http_annotations.dart';

get embla => [new HttpBootstrapper(pipeline: pipe(MyController))];

class MyController extends Controller {
  /// GET /action  ->  'Response'
  @Get() action() {
    return 'Response';
  }

  /// POST /endpoint  ->  302 /
  @Post('endpoint') methodName() {
    return redirect('/action');
  }
}
```

Since controllers are middleware too, we can easily route our controllers to endpoints like this:

```dart
Route.all('pages/*', PagesController)
```
