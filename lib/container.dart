import 'src/container.dart' as implementation;

class InjectionException implements Exception {
  final String message;
  final InjectionException because;

  InjectionException(this.message, [this.because]);

  String toString() => 'InjectionException: $reason';

  String get reason => '$message' +
    (because == null ? '' : ' because\n  ${because.reason}');
}

class BindingException implements Exception {
  final String message;

  BindingException(this.message);

  String toString() => 'BindingException: $message';
}

abstract class IoCContainer {
  factory IoCContainer() => new implementation.IoCContainer();

  /// Creates a new instance of the provided [type], resolving the
  /// constructor parameters automatically.
  ///
  ///     class A {}
  ///
  ///     class B {
  ///       B(A a) {
  ///         print(a); // Instance of 'A'
  ///       }
  ///     }
  dynamic/*=T*/ make/*<T>*/(Type/* extends T*/ type);

  /// Finds all parameters in a [function] and injects the dependencies automatically.
  ///
  ///     resolve((Dependency dep) {
  ///       print(dep); // Instance of 'Dependency'
  ///     });
  dynamic/*=T*/ resolve/*<T>*/(Function/* -> T*/ function);

  /// Returns a lazily resolved version of [function], injecting the arguments passed in to the
  /// curried function into the original function by their type.
  ///
  ///     var curried = curry((Dependency dependency, String string) {
  ///       print('$dependency, $string');
  ///     });
  ///     curried("Hello!"); // Instance of 'Dependency', Hello!
  ///
  /// You can invoke the curried function just like you would the original, but leave out any
  /// argument any the container will inject the arguments you don't supply.
  ///
  ///     var curried = curry((String s, int i, {a, Dependency b, c}) {});
  ///     curried("s", 0, a: 0, c: 0); // Named parameter b will be injected
  Function curry(Function function);

  /// Returns a copy of the container, with an implementation of a [type] bound. Subsequent requests
  /// for injections of the [type] will be provided the [to] value.
  ///
  /// [to] can be either a [Type] that is an instance of, or a subtype of [type], or an instance
  /// of [type].
  ///
  ///     bind(A, to: B).make(A); // Instance of 'B'
  ///     bind(A, to: new A()).make(A); // Instance of 'A'
  ///     bind(A, to: new B()).make(A); // Instance of 'B'
  IoCContainer bind(Type type, {to});

  /// Acts like [bind], but instead of binding to a specific type request, it gets bound to named
  /// parameters with this [name].
  ///
  /// Without bindings, named parameters will only be resolved if they don't have a default value.
  /// If they have no default value, they will be resolved if they can, but will be set
  /// to `null` if the resolve fails.
  ///
  /// [to] will only be bound to parameters with a compatible type. Therefore, multiple bindings
  /// can be made to the same [name]. The value that will be injected is chosen based on the type
  /// annotation of the parameter:
  ///
  ///     final c = bindName("x", to: 123)
  ///              .bindName("x", to: "string")
  ///              .bindName("x", to: SomeImplementation);
  ///
  ///     c.resolve(({y}) {
  ///       print(y); // null <-- nothing is bound to y, so attempt to make or else return null
  ///     });
  ///     c.resolve(({num x}) {
  ///       print(x); // 123 <-- bound int is assignable to num
  ///     });
  ///     c.resolve(({String x}) {
  ///       print(x); // "string" <-- bound String is assignable to String
  ///     });
  ///     c.resolve(({SomeClass x}) {
  ///       print(x); // Instance of 'SomeClass' <-- no binding is assignable, so attempt to make
  ///     });
  ///     c.resolve(({SomeClass x: defaultValue}) {
  ///       print(x); // defaultValue <-- no binding is assignable, so use default value
  ///     });
  ///     c.resolve(({SomeInterface x}) {
  ///       print(x); // Instance of 'SomeImplementation'
  ///                 // ^-- bound SomeImplementation is assignable to SomeInterface
  ///     });
  ///     c.resolve(({x}) {
  ///       print(x); // 123 <-- everything is assignable to dynamic, so choose first binding
  ///     });
  IoCContainer bindName(String name, {to});

  /// Returns a copy of the container, with a decorator for this [type] bound.
  ///
  ///     class Greeter {
  ///       greet() => "Hello, world";
  ///     }
  ///
  ///     class ExclaimDecorator implements Greeter {
  ///       final Greeter _super;
  ///       ExclaimDecorator(this._super);
  ///       greet() => _super.greet() + '!';
  ///     }
  ///
  ///     class ScreamDecorator implements Greeter {
  ///       final Greeter _super;
  ///       ScreamDecorator(this._super);
  ///       greet() => _super.greet().toUpperCase();
  ///     }
  ///
  ///     print(
  ///       decorate(Greeter, withDecorator: ExclaimDecorator)
  ///      .decorate(Greeter, withDecorator: ExclaimDecorator)
  ///      .decorate(Greeter, withDecorator: ScreamDecorator)
  ///      .make(Greeter)
  ///      .greet()
  ///     ); // HELLO, WORLD!!
  IoCContainer decorate(Type type, {Type withDecorator});

  /// Combines all bindings from the [other] container with this one's, and returns a new
  /// instance that combines the bindings. The bindings in [other] takes precedence.
  ///
  ///     var a = new IoCContainer().bind(int, toValue: 1).bind(String, toValue: "x");
  ///     var b = new IoCContainer().bind(int, toValue: 2);
  ///     var c = a.apply(b);
  ///     c.resolve((int i, String s) {
  ///       print(s); // x
  ///       print(i); // 2
  ///     });
  IoCContainer apply(IoCContainer other);
}
