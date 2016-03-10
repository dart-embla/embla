import 'package:quark/unit.dart';
import 'package:embla/container.dart';
export 'package:quark/init.dart';

class IoCContainerTest extends UnitTest {
  IoCContainer get c => new IoCContainer();

  Matcher get throwsInjectionException => throwsA(new isInstanceOf<InjectionException>());
  Matcher get throwsBindingException => throwsA(new isInstanceOf<BindingException>());

  @test
  itInstantiatesClasses() {
    expect(c.make(SimpleClass), new isInstanceOf<SimpleClass>());
  }

  @test
  itResolvesFunctions() {
    expect(c.resolve((SimpleClass s) => s), new isInstanceOf<SimpleClass>());
  }

  @test
  itCannotInstantiateATypedef() {
    expect(() => c.make(Typedef), throwsInjectionException);
  }

  @test
  itThrowsWhenAClassIsAbstract() {
    expect(() => c.make(String), throwsInjectionException);
  }

  @test
  itInstantiatesTheDependencies() {
    final ClassWithDependency i = c.make(ClassWithDependency);
    expect(i, new isInstanceOf<ClassWithDependency>());
    expect(i.dep, new isInstanceOf<SimpleClass>());
  }

  @test
  itCanBindATypeToAnother() {
    expect(c.bind(AbstractClass, to: ConcreteClass).make(AbstractClass), new isInstanceOf<ConcreteClass>());
    expect(c.bind(AbstractClass, to: new ConcreteClass()).make(AbstractClass), new isInstanceOf<ConcreteClass>());
  }

  @test
  itThrowsIfBindingIsIncompatible() {
    expect(() => c.bind(AbstractClass, to: SimpleClass), throwsBindingException);
    expect(() => c.bind(AbstractClass, to: ""), throwsBindingException);
  }

  @test
  bindingsPropagate() {
    expect(() => c.make(ClassWithNestedAbstractDependency), throwsInjectionException);
    expect(
      c.bind(AbstractClass, to: ConcreteClass).make(ClassWithNestedAbstractDependency),
      new isInstanceOf<ClassWithNestedAbstractDependency>()
    );
  }

  @test
  itTriesToResolveNamedArgumentsByDefault() {
    expect(c.resolve(({SimpleClass c, String s}) => '$c,$s'), "Instance of 'SimpleClass',null");
  }

  @test
  itCanBindNamedArguments() {
    expect(c.bindName("s", to: "string").resolve(({s}) => '$s'), "string");

    final boundC = c.bindName("x", to: 123)
                    .bindName("x", to: "string")
                    .bindName("x", to: ConcreteClass);

    boundC.resolve(({num x}) {
      expect(x, 123);
    });
    boundC.resolve(({String x}) {
      expect(x, "string");
    });
    boundC.resolve(({SimpleClass x}) {
      expect(x, new isInstanceOf<SimpleClass>());
    });
    boundC.resolve(({SimpleClass x: const DefaultValueSimpleClass()}) {
      expect(x, new isInstanceOf<DefaultValueSimpleClass>());
    });
    boundC.resolve(({AbstractClass x}) {
      expect(x, new isInstanceOf<ConcreteClass>());
    });
    boundC.resolve(({x}) {
      expect(x, 123);
    });
  }

  @test
  itUsesDefaultValueIfNoBindingExists() {
    expect(c.resolve(({s: 'default'}) => s), 'default');
  }

  @test
  itThrowsIfAMoreGeneralNamedBindingHasAlreadyBeenMade() {
    expect(
      () => c.bindName('x', to: ConcreteClass).bindName('x', to: ConcreteSubClass),
      throwsBindingException
    );
    expect(
      () => c.bindName('x', to: dynamic).bindName('x', to: SimpleClass),
      throwsBindingException
    );
  }

  @test
  itStillAppliesOrdinaryBindingRulesWhenInjectingTypeBoundByName() {
    expect(
      c.bindName('x', to: AbstractClass).bind(AbstractClass, to: ConcreteClass).resolve(({x}) => x),
      new isInstanceOf<ConcreteClass>()
    );
    expect(
      c.bind(AbstractClass, to: ConcreteClass).bindName('x', to: AbstractClass).resolve(({x}) => x),
      new isInstanceOf<ConcreteClass>()
    );
  }

  @test
  itCanCurryFunctions() {
    final curried = c.curry((SimpleClass s) => s);
    expect(curried(), new isInstanceOf<SimpleClass>());
  }

  @test
  curriedFunctionsCanBeSuppliedArguments() {
    final curried = c.curry((SimpleClass c, String s) => '$c,$s');
    expect(curried, throwsInjectionException);
    expect(curried("x"), "Instance of 'SimpleClass',x");

    expect(
      c.curry((p, {SimpleClass x, y}) => '$p,$x,$y')(123, y: 456),
      "123,Instance of 'SimpleClass',456"
    );
  }

  @test
  itCanRegisterDecorators() {
    final Cat cat = c
      .decorate(Cat, withDecorator: ScreamDecorator)
      .decorate(Cat, withDecorator: ExclamationDecorator)
      .decorate(Cat, withDecorator: ExclamationDecorator)
      .make(Cat);

    expect(cat.meow, 'MEOW!!');
  }

  @test
  itThrowsWhenTryingToDecorateWithClassThatDoesntImplementDecoratee() {
    expect(() => c.decorate(Cat, withDecorator: String), throwsBindingException);
  }

  @test
  itThrowsWhenTryingToDecorateWithClassThatDoesntInjectDecoratee() {
    expect(() => c.decorate(Cat, withDecorator: InvalidDecorator), throwsBindingException);
  }

  @test
  itChecksForNotProvidedArguments() {
    c.bind(String, to: null);
    expect(() => c.bind(String), throwsArgumentError);
    expect(() => c.bind(null, to: null), throwsArgumentError);

    c.bindName('x', to: null);
    expect(() => c.bindName('x'), throwsArgumentError);
    expect(() => c.bindName(null, to: null), throwsArgumentError);

    expect(() => c.curry(null), throwsArgumentError);
    expect(() => c.resolve(null), throwsArgumentError);
    expect(() => c.make(null), throwsArgumentError);

    expect(() => c.decorate(null), throwsArgumentError);
    expect(() => c.decorate(null, withDecorator: null), throwsArgumentError);
    expect(() => c.decorate(String), throwsArgumentError);
    expect(() => c.decorate(String, withDecorator: null), throwsArgumentError);
    expect(() => c.decorate(null, withDecorator: String), throwsArgumentError);
  }

  @test
  itCanCombineItselfWithAnotherContainer() {
    final ca = c.bind(String, to: 'x').bind(int, to: 1);
    final cb = c.bind(String, to: 'y');
    final cc = ca.apply(cb);
    expect(cc.make(String), 'y');
    expect(cc.make(int), 1);
  }
}

typedef Typedef();

class SimpleClass {
  const SimpleClass();
}

class DefaultValueSimpleClass implements SimpleClass {
  const DefaultValueSimpleClass() : super();
}

abstract class AbstractClass {}

class ClassWithDependency {
  final SimpleClass dep;
  ClassWithDependency(this.dep);
}

class ConcreteClass implements AbstractClass {}
class ConcreteSubClass extends ConcreteClass {}

class ClassWithAbstractDependency {
  final AbstractClass dep;
  ClassWithAbstractDependency(this.dep);
}

class ClassWithNestedAbstractDependency {
  final ClassWithAbstractDependency dep;
  ClassWithNestedAbstractDependency(this.dep);
}

class Cat {
  String get meow => 'meow';
}

class ScreamDecorator implements Cat {
  final Cat cat;
  ScreamDecorator(this.cat);
  String get meow => cat.meow.toUpperCase();
}

class ExclamationDecorator implements Cat {
  final Cat cat;
  ExclamationDecorator(this.cat);
  String get meow => cat.meow + '!';
}

class InvalidDecorator implements Cat {
  String get meow => "doesn't decorate!";
}
