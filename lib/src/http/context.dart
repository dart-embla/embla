import 'dart:async';
import 'dart:collection' show MapBase;
import '../../container.dart';

const _contextZoneValueKey = '__emblaHttpContext';

HttpContext _testingContext;

setUpContextForTesting({Map<String, dynamic> values}) {
  _testingContext = new HttpContext({
    '__container': new IoCContainer()
  }..addAll(values ?? {}));
}

bool get isInHttpContext {
  return _testingContext != null || Zone.current[_contextZoneValueKey] != null;
}

HttpContext get context => _testingContext ?? Zone.current[_contextZoneValueKey]
  ?? (throw new Exception('You have to [runInContext] before accessing the current context'));

dynamic/*=T*/ runInContext/*<T>*/(IoCContainer container, dynamic/*=T*/ body()) {
  return runZoned(body, zoneValues: {
    _contextZoneValueKey: new HttpContext({
      '__container': container
    })
  }) as dynamic/*=T*/;
}

class HttpContext extends MapBase<String, dynamic> {
  final Map<String, dynamic> _values;

  HttpContext(this._values);

  void _ensureIsntReservedKey(String key) {
    if (key.startsWith('__')) {
      throw new UnimplementedError('Context keys cannot start with two underscores.');
    }
  }

  Map<String, dynamic> get locals => (_values['__locals'] ??= {}) as Map<String, dynamic>;
  IoCContainer get container => _values['__container'] as IoCContainer;
  void set container(IoCContainer other) {
    _values['__container'] = container.apply(other);
  }

  operator [](Object key) {
    _ensureIsntReservedKey('$key');
    return _values[key];
  }

  @override
  void operator []=(String key, value) {
    _ensureIsntReservedKey(key);
    return _values[key] = value;
  }

  @override
  void clear() {
    throw new UnsupportedError("Clearing the context will mess things up.");
  }

  @override
  Iterable<String> get keys => _values.keys.where((k) => !k.startsWith('__'));

  @override
  remove(Object key) {
    _ensureIsntReservedKey(key);
    _values.remove(key);
  }
}
