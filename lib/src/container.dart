import 'dart:mirrors';

import '../container.dart' as interface show IoCContainer;
import '../container.dart' show InjectionException, BindingException;

typedef T Factory<T>(IoCContainer container);
typedef InstanceMirror Invoker(List positional, Map<Symbol, dynamic> named);

class Nothing {
  const Nothing();
}

const nothing = const Nothing();

Map<dynamic/*=K*/, dynamic/*=V*/> merge/*<K, V>*/(Map<dynamic/*=K*/, dynamic/*=V*/> a, Map<dynamic/*=K*/, dynamic/*=V*/> b) {
  return new Map.unmodifiable({}..addAll(a)..addAll(b));
}

class IoCContainer implements interface.IoCContainer {
  final Map<Type, Factory> bindings;
  final Map<Symbol, Map<TypeMirror, Factory>> nameBindings;

  IoCContainer({this.bindings: const {}, this.nameBindings: const {}});

  @override
  IoCContainer bind(Type type, {to: nothing}) {
    _checkForNull('type', type);
    _checkForNothing('to', to);
    _checkAssignable(
      type,
      to: to,
      message: '${to is Type ? to : to.runtimeType} cannot be assigned to $type'
    );
    return new IoCContainer(
      bindings: merge/*<Type, Factory>*/(bindings, {type: _makeFactory(to)}),
      nameBindings: nameBindings
    );
  }

  void _checkAssignable(Type type, {to, String message}) {
    if (!_isAssignable(type, to: to)) {
      throw new BindingException(message);
    }
  }

  bool _isAssignable(Type type, {to}) {
    if (to == Null || to == null) return true;
    return _getType(to).isAssignableTo(reflectType(type));
  }

  Factory _makeFactory(binding) {
    if (binding is Type) {
      return (container) => container.make(binding);
    }
    return (_) => binding;
  }

  @override
  IoCContainer bindName(String name, {to: nothing}) {
    _checkForNull('name', name);
    _checkForNothing('to', to);
    final nameSymbol = new Symbol(name);

    _checkForMoreGenericExistingNameBinding(name, nameSymbol, _getType(to));

    return new IoCContainer(
      bindings: bindings,
      nameBindings: merge/*<Symbol, Map<TypeMirror, Factory>>*/(nameBindings, {
        new Symbol(name): merge/*<TypeMirror, Factory>*/(nameBindings[nameSymbol] ?? {}, {
          _getType(to): _makeFactory(to)
        })
      })
    );
  }

  void _checkForMoreGenericExistingNameBinding(String name, Symbol symbol, TypeMirror newBindType) {
    if (!nameBindings.containsKey(symbol)) return;

    final bindings = nameBindings[symbol];

    final moreGenericBinding = bindings.keys
      .firstWhere((t) => newBindType.isSubtypeOf(t), orElse: () => null);

    if (moreGenericBinding == null) return;

    throw new BindingException(
      'Cannot bind ${newBindType.reflectedType} to parameter named $name '
      'because ${moreGenericBinding.reflectedType} is already bound to the same name '
      'and is more generic'
    );
  }

  TypeMirror _getType(binding) {
    if (binding is Type) {
      return reflectType(binding);
    }
    return reflect(binding).type;
  }

  @override
  Function curry(Function function) {
    _checkForNull('function', function);
    return new CurriedFunction(this, reflect(function));
  }

  @override
  IoCContainer decorate(Type type, {Type withDecorator}) {
    _checkForNull('type', type);
    _checkForNull('withDecorator', withDecorator);

    if (!reflectType(withDecorator).isSubtypeOf(reflectType(type))) {
      throw new BindingException(
        '$withDecorator is not a subtype of $type. '
        'Decorators must implement their decoratee.'
      );
    }

    if (!_hasTypeAnnotationInConstructor(withDecorator, type)) {
      throw new BindingException(
        '$withDecorator must inject $type in its constructor to be '
        'a valid decorator.'
      );
    }

    return new IoCContainer(
      bindings: merge/*<Type, Factory>*/(bindings, {
        type: (container) {
          final decoratee = make(type);
          return container.bind(type, to: decoratee).make(withDecorator);
        }
      }),
      nameBindings: nameBindings
    );
  }

  bool _hasTypeAnnotationInConstructor(Type type, Type annotation) {
    final ClassMirror classMirror = reflectType(type);
    final MethodMirror constructor = classMirror.declarations[classMirror.simpleName];
    return constructor.parameters.any((p) => p.type.reflectedType == annotation);
  }

  @override
  dynamic/*=T*/ make/*<T>*/(Type/* extends T*/ type) {
    _checkForNull('type', type);
    if (_hasBinding(type)) {
      return _binding/*<T>*/(type);
    }

    final TypeMirror typeMirror = reflectType(type);
    if (typeMirror is! ClassMirror)
      throw new InjectionException('Only classes can be instantiated. $type is not a class.');
    final ClassMirror classMirror = typeMirror as ClassMirror;
    final MethodMirror constructor = classMirror.declarations[typeMirror.simpleName];
    try {
      return _resolve/*<T>*/(
        constructor?.parameters ?? [],
        (p, n) => classMirror.newInstance(const Symbol(''), p, n)
      );
    } on AbstractClassInstantiationError {
      throw new InjectionException('$type is abstract.');
    } on NoSuchMethodError catch(e) {
      if ('$e'.startsWith("No constructor '$type' declared in class '$type'.")) {
        throw new InjectionException('$type has no default constructor.');
      }
      rethrow;
    } on InjectionException catch(e) {
      throw new InjectionException('Cannot instantiate $type', e);
    }
  }

  bool _hasBinding(Type type) => bindings.containsKey(type);

  dynamic/*=T*/ _binding/*<T>*/(Type type) => bindings[type](this) as dynamic/*=T*/;

  @override
  dynamic/*=T*/ resolve/*<T>*/(Function/* -> T*/ function) {
    _checkForNull('function', function);
    final ClosureMirror closureMirror = reflect(function);
    return _resolve/*<T>*/(
      closureMirror.function.parameters,
      closureMirror.apply
    );
  }

  dynamic/*=T*/ _resolve/*<T>*/(Iterable<ParameterMirror> params, Invoker invoker) {
    return invoker(_positional(params), _named(params)).reflectee as dynamic/*=T*/;
  }

  List _positional(Iterable<ParameterMirror> params) {
    return params
      .where((p) => !p.isNamed)
      .map((p) => p.type.reflectedType)
      .map(make)
      .toList();
  }

  Map<Symbol, dynamic> _named(Iterable<ParameterMirror> params) {
    final Iterable<ParameterMirror> p = params.where((p) => p.isNamed);
    return new Map.fromIterables(
      p.map((p) => p.simpleName),
      p.map((p) {
        if (nameBindings.containsKey(p.simpleName)) {
          return _getBoundNamed(p);
        }
        return _makeOrNull(p.type.reflectedType);
      })
    );
  }

  dynamic/*=T*/ _getBoundNamed/*<T>*/(ParameterMirror named) {
    final record = nameBindings[named.simpleName];
    final requestedType = named.type;
    for (final boundType in record.keys) {
      if (boundType.isAssignableTo(requestedType)) {
        return record[boundType](this) as dynamic/*=T*/;
      }
    }
    final returnValue = named.defaultValue?.reflectee ?? _makeOrNull(requestedType.reflectedType);
    return returnValue as dynamic/*=T*/;
  }

  dynamic/*=T*/ _makeOrNull/*<T>*/(Type type) {
    try {
      return make/*<T>*/(type);
    } on InjectionException {
      return null;
    }
  }

  void _checkForNull(String paramName, value) {
    if (value == null) {
      throw new ArgumentError.notNull(paramName);
    }
  }

  void _checkForNothing(String paramName, value) {
    if (value == nothing) {
      throw new ArgumentError.value(null, paramName, 'Must be supplied');
    }
  }

  @override
  IoCContainer apply(interface.IoCContainer other) {
    if (other is! IoCContainer) {
      throw new ArgumentError.value(other, 'other', 'Must be the same implementation');
    }
    final IoCContainer otherC = other;
    return new IoCContainer(
      bindings: merge(bindings, otherC.bindings),
      nameBindings: merge(nameBindings, otherC.nameBindings)
    );
  }
}

class CurriedFunction implements Function {
  final IoCContainer container;
  final ClosureMirror closure;

  CurriedFunction(this.container, this.closure);

  @override
  bool operator ==(Object other) {
    return other.hashCode == hashCode;
  }

  noSuchMethod(Invocation invocation) {
    if (invocation.memberName != #call) {
      return super.noSuchMethod(invocation);
    }
    return closure.apply(
      _positional(invocation.positionalArguments).toList(),
      _named(invocation.namedArguments)
    ).reflectee;
  }

  Iterable _positional(Iterable args) {
    return closure
      .function
      .parameters
      .where((p) => !p.isNamed)
      .map((parameter) {
        for (final a in args) {
          if (reflect(a).type.isAssignableTo(parameter.type)) {
            return a;
          }
        }
        return container.make(parameter.type.reflectedType);
      });
  }

  Map<Symbol, dynamic> _named(Map<Symbol, dynamic> args) {
    final params = closure.function.parameters.where((p) => p.isNamed);
    return new Map.fromIterables(
      params.map((p) => p.simpleName),
      params.map((p) {
        if (args.containsKey(p.simpleName)) {
          return args[p.simpleName];
        }
        return container.make(p.type.reflectedType);
      })
    );
  }
}
