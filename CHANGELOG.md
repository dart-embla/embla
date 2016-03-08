# Changelog

## Pre 0.2
An empty Embla app is an empty getter called `embla` in the script, with an export statement.

```dart
export 'package:embla/bootstrap.dart';
get embla => [];
```

The getter should return a `List<Bootstrapper>`.

```dart
import 'package:embla/application.dart';
export 'package:embla/bootstrap.dart';

List<Bootstrapper> get embla => [];
```

Bootstrappers attach listeners to application lifetime hooks.

```dart
import 'package:embla/application.dart';
export 'package:embla/bootstrap.dart';

get embla => [
  new MyBootstrapper()
];

class MyBootstrapper extends Bootstrapper {
  @Hook.init
  init() {
    print('Starting the application up!');
  }

  @Hook.exit
  exit() {
    print('Shutting the application down!');
  }
}
```

Methods in a bootstrapper can use Dependency Injection to inject classes. Since Embla uses a stateless
IoC container, adding bindings to the container returns a new instance. To push the new bindings into
the application, the bootstrappers can return the new container in any of its methods.

The container itself is available from the `Bootstrapper` superclass.

```dart
class AddsBindingsBootstrapper extends Bootstrapper {
  @Hook.bindings
  bindings() {
    return container.bind(SomeAbstractClass, to: SomeConcreteClass);
  }
}
```

The hooks, as well as the container, is documented in doc comments.

#### HTTP Pipeline
The basic Embla library comes with an `HttpBootstrapper`, which takes some configuration as named
parameters. One of which is the `pipeline` parameter, expecting a `Pipeline`.

The `pipe` helper creates a `Pipeline` from one or more `Middleware`:

```dart
import 'package:embla/http.dart';
export 'package:embla/bootstrap.dart';

get embla => [
  new HttpBootstrapper(
    pipeline: pipe(
      SomeMiddleware
    )
  )
];
```

There are some middleware that comes out-of-the-box, for routing as well as for some common tasks like
removing trailing slashes from URLs, parsing the request body, or handling errors thrown in the pipeline.

