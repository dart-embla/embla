import 'package:quark/unit.dart';
export 'package:quark/init.dart';
import 'package:embla/application.dart';

class BootstrapTest extends UnitTest {
  Application app;
  TestBootstrapper bootstrapper;

  @before
  setUp() async {
    app = await Application.boot([
      new TestBootstrapper()
    ]);
    bootstrapper = app.bootstrappers[0];
  }

  @after
  tearDown() async {
    await app.exit();
  }

  @test
  itInstantiatesBootstrappers() {
    expect(bootstrapper, new isInstanceOf<TestBootstrapper>());
  }

  @test
  itInitializesBootstrappers() {
    bootstrapper.verify();
  }
}

class TestBootstrapper extends Bootstrapper {
  final List<String> history = [];

  @Hook.init
  runInit() => history.add('init');

  @Hook.init
  runInit2() => history.add('init2');

  @Hook.afterInit
  runAfterInit() => history.add('afterInit');

  @Hook.beforeBindings
  runBeforeBindings() => history.add('beforeBindings');

  @Hook.bindings
  runBindings() => history.add('bindings');

  @Hook.afterBindings
  runAfterBindings() => history.add('afterBindings');

  @Hook.beforeInteraction
  runBeforeInteraction() => history.add('beforeInteraction');

  @Hook.interaction
  runInteraction() => history.add('interaction');

  @Hook.afterInteraction
  runAfterInteraction() => history.add('afterInteraction');

  @Hook.beforeReaction
  runBeforeReaction() => history.add('beforeReaction');

  @Hook.reaction
  runReaction() => history.add('reaction');

  @Hook.afterReaction
  runAfterReaction() => history.add('afterReaction');

  @Hook.beforeExit
  runBeforeTeardown() => history.add('beforeExit');

  @Hook.exit
  runTeardown() => history.add('exit');

  void verify() {
    expect(history, [
      'init',
      'init2',
      'afterInit',
      'beforeBindings',
      'bindings',
      'afterBindings',
      'beforeInteraction',
      'interaction',
      'afterInteraction',
      'beforeReaction',
      'reaction',
      'afterReaction',
    ]);
  }
}
