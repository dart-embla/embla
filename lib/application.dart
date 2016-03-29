import 'dart:async';
import 'dart:mirrors';
import 'container.dart';
import 'src/util/trace_formatting.dart';
import 'src/util/container_state.dart';

class Application {
  final IoCContainer container;
  final List<Bootstrapper> bootstrappers;

  Application._(this.container, this.bootstrappers);

  static Future<Application> boot(Iterable<Bootstrapper> bootstrappers) async {
    final containerState = new ContainerState(new IoCContainer());
    return new Application._(
        containerState.state,
        new List.unmodifiable(
            (await Future.wait(
                bootstrappers.map((b) => _timeline(containerState, b))
            )).where((b) => b != null)
        )
    );
  }

  static Future _timeline(ContainerState state, Bootstrapper bootstrapper) async {
    try {
      if (bootstrapper is! Bootstrapper) {
        throw new ArgumentError('${bootstrapper.runtimeType} is not a Bootstrapper!');
      }
      await bootstrapper._run(state);
      return bootstrapper;
    } catch (e, s) {
      TraceFormatter.print(e, s);
      return null;
    }
  }

  Future exit() async {
    await Future.wait(bootstrappers.map/*<Future>*/((b) async => b._exit()));
  }
}

/// In [Bootstrapper]s, methods can be annotated with hooks to attach scripts to the overall
/// setup and teardown procedure of the application.
abstract class Hook {
  Hook._();

  /// This hook will be the first to run, and should contain plugin interal initialization.
  static const init = 'bootstrap:init';
  /// This hook will be run after every [Bootstrapper] has run its [init] hook(s).
  static const afterInit = 'bootstrap:afterInit';

  /// Any bindings that must be made to the IoCContainer before the actual [bindings] hook is
  /// run will be made in a [beforeBindings] hook.
  static const beforeBindings = 'bootstrap:beforeBindings';
  /// This hook is the main place to make bindings in the global [IoCContainer] that will be
  /// available throughout the lifetime of the application.
  static const bindings = 'bootstrap:bindings';
  /// This hook will run just after every [Bootstrapper] has run its main [bindings] hook(s).
  static const afterBindings = 'bootstrap:afterBindings';

  /// This hook is run in preparation of the main [interaction] hook(s).
  static const beforeInteraction = 'bootstrap:beforeInteraction';
  /// This hook should contain any cross [Bootstrapper] communication.
  static const interaction = 'bootstrap:interaction';
  /// This hook is run just after the main [interaction] hook(s).
  static const afterInteraction = 'bootstrap:afterInteraction';

  /// This hook is run in preparation of the main [reaction] hook(s).
  static const beforeReaction = 'bootstrap:beforeReaction';
  /// This hook should contain any scripts that is a reaction to the messages sent to other
  /// [Bootstrapper]s in the [interaction] hook(s).
  static const reaction = 'bootstrap:reaction';
  /// This hook is run just after the main [reaction] hook(s).
  static const afterReaction = 'bootstrap:afterReaction';

  /// This hook will be run after the program has received the exit command.
  static const beforeExit = 'bootstrap:beforeExit';
  /// This final hook contains the deinitialization scripts, in which all ports and streams
  /// must be closed.
  static const exit = 'bootstrap:exit';
}

/// Bootstrappers bootstrap different components of an Embla application. Every Bootstrapper
/// adds one or more hooks to itself, each in which it can run initialization or deinitialization
/// scripts. Check out the [Hook] class for information about each hook.
///
/// Each hook _can_ return either an [IoCContainer] or a [Future<IoCContainer>], in which case
/// all changes to the IoC Container will be applied to the global container in the application.
///
///     class MyBoostrapper extends Bootstrapper {
///       @Hook.init
///       init() {
///         print('MyBootstrapper is starting!');
///       }
///
///       @Hook.bindings
///       bindings() {
///         return container
///           .bind(SomeInterface, toSubtype: SomeImplementation);
///       }
///     }
abstract class Bootstrapper {
  IoCContainer get container => _containerState?.state ?? (throw new Exception('To manually run hooks, first run $runtimeType#attach()'));

  InstanceMirror _mirror;
  ContainerState _containerState;
  Iterable<MethodMirror> __methods;

  void attach([IoCContainer container]) {
    _containerState = new ContainerState(container ?? new IoCContainer());
  }

  Future _run(ContainerState containerState) async {
    _containerState = containerState;
    _mirror = reflect(this);
    __methods = _methods();
    await _callAnnotation(__methods, Hook.init);
    await _callAnnotation(__methods, Hook.afterInit);
    await _callAnnotation(__methods, Hook.beforeBindings);
    await _callAnnotation(__methods, Hook.bindings);
    await _callAnnotation(__methods, Hook.afterBindings);
    await _callAnnotation(__methods, Hook.beforeInteraction);
    await _callAnnotation(__methods, Hook.interaction);
    await _callAnnotation(__methods, Hook.afterInteraction);
    await _callAnnotation(__methods, Hook.beforeReaction);
    await _callAnnotation(__methods, Hook.reaction);
    await _callAnnotation(__methods, Hook.afterReaction);
  }

  Future _exit() async {
    try {
      await _callAnnotation(__methods, Hook.beforeExit);
      await _callAnnotation(__methods, Hook.exit);
    } catch (e, s) {
      TraceFormatter.print(e, s);
    }
  }

  Future _callAnnotation(Iterable<MethodMirror> methods, annotation) async {
    await Future.wait(
        _annotated(methods, annotation)
            .map/*<Future>*/((c) => _runClosure(c))
    );
  }

  Iterable<MethodMirror> _methods() {
    return _mirror.type.instanceMembers.values
        .where((i) => i is MethodMirror && i.isRegularMethod);
  }

  Iterable<MethodMirror> _annotated(Iterable<MethodMirror> methods, annotation) {
    return methods.where((m) => m.metadata.any((t) => t.reflectee == annotation));
  }

  Future _runClosure(MethodMirror method) async {
    ClosureMirror closure = _mirror.getField(method.simpleName) as ClosureMirror;
    await traceIdentifier_PJ9ZCKjkkKPFYjgH3jkW(() async {
      final response = await _containerState.state.resolve(closure.reflectee);
      if (response is IoCContainer) {
        _containerState.state = response;
      }
    });
  }
}
