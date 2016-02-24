import 'dart:collection';

Map<K, V> concatMaps/*<K, V>*/(
    Map<K, V> a,
    Map<K, V> b
) {
  return new Map<K, V>.unmodifiable({}..addAll(a)..addAll(b));
}

Iterable<E> concatIterables/*<E>*/(
    Iterable<E> a,
    Iterable<E> b
) {
  return new _ConcatinatedIterable<E>(a, b);
}

class _ConcatinatedIterable<E> extends IterableBase<E> implements Iterable<E> {
  final Iterable<E> a;
  final Iterable<E> b;

  Iterator<E> get iterator {
    return new _ConcatinatedIterator<E>(a.iterator, b.iterator);
  }

  _ConcatinatedIterable(this.a, this.b);
}

class _ConcatinatedIterator<E> implements Iterator<E> {
  final Iterator<E> a;
  final Iterator<E> b;
  bool _aIsNotDone = true;

  _ConcatinatedIterator(this.a, this.b);

  E get current {
    if (_aIsNotDone) {
      return a.current;
    } else {
      return b.current;
    }
  }

  bool moveNext() {
    if (_aIsNotDone && a.moveNext()) {
      return true;
    } else {
      _aIsNotDone = false;
    }
    if (b.moveNext()) {
      return true;
    }
    return false;
  }
}
