import 'dart:async';
import 'dart:mirrors';
import 'package:container/container.dart';
import 'src/util/trace_formatting.dart';
import 'src/util/helper_container.dart';

class Application {
  final Container container;
  final List<Bootstrapper> bootstrappers;

  Application._(this.container, this.bootstrappers);

  static Future<Application> boot(
      Iterable<Bootstrapper> bootstrappers
      ) async {
    final container = helperContainer;
    container.singleton(container, as: Container);
    return new Application._(
        container,
        new List.unmodifiable(
            (await Future.wait(
                bootstrappers
                    .map((b) => _timeline(container, b))
            )).where((b) => b != null)
        )
    );
  }

  static Future _timeline(Container container, Bootstrapper bootstrapper) async {
    try {
      await bootstrapper._run(container);
      return bootstrapper;
    } catch (e, s) {
      TraceFormatter.print(e, s);
      return null;
    }
  }

  Future exit() async {
    await Future.wait(bootstrappers.map((b) async => b._exit()));
  }
}

abstract class Hook {
  Hook._();

  static const init = 'bootstrap:init';
  static const afterInit = 'bootstrap:afterInit';

  static const beforeBindings = 'bootstrap:beforeBindings';
  static const bindings = 'bootstrap:bindings';
  static const afterBindings = 'bootstrap:afterBindings';

  static const beforeInteraction = 'bootstrap:beforeInteraction';
  static const interaction = 'bootstrap:interaction';
  static const afterInteraction = 'bootstrap:afterInteraction';

  static const beforeReaction = 'bootstrap:beforeReaction';
  static const reaction = 'bootstrap:reaction';
  static const afterReaction = 'bootstrap:afterReaction';

  static const beforeExit = 'bootstrap:beforeExit';
  static const exit = 'bootstrap:exit';
}

abstract class Bootstrapper {
  Container get container => _container;

  InstanceMirror _mirror;
  Container _container;
  Iterable<MethodMirror> __methods;

  Future _run(Container container) async {
    _container = container;
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
            .map((c) => _runClosure(c))
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
    await traceIdentifier_PJ9ZCKjkkKPFYjgH3jkW(() {
      return _container.resolve(closure.reflectee);
    });
  }
}