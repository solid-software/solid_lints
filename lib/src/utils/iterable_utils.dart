import 'package:collection/collection.dart';

/// Utility methods for [Iterable] operations.
abstract final class IterableUtils {
  /// Generates a sequence starting with [seed] and producing subsequent
  /// elements with [next] until [next] returns `null`.
  static Iterable<T> iterate<T>(T seed, T? Function(T current) next) sync* {
    var current = seed;
    while (true) {
      yield current;
      final nextElement = next(current);
      if (nextElement == null) break;
      current = nextElement;
    }
  }
}

/// Extension on [Iterable] to sort by multiple keys.
extension MultiSortedByIterable<T> on Iterable<T> {
  /// Sorts this iterable by multiple keys sequentially.
  ///
  /// The first key selector that produces a non-zero comparison is used.
  List<T> multiSortedBy(List<Comparable<dynamic> Function(T)> keys) => sorted(
    (a, b) =>
        keys
            .map((key) => key(a).compareTo(key(b)))
            .firstWhereOrNull((comparison) => comparison != 0) ??
        0,
  );
}

/// Extension on [Iterable] that provides a [pairwise] method for grouping
/// elements.
extension IterablePairwise<T> on Iterable<T> {
  /// Returns an iterable of overlapping pairs of elements.
  /// For example, `[1, 2, 3].pairwise()` returns `[(1, 2), (2, 3)]`.
  Iterable<(T, T)> pairwise() sync* {
    for (var i = 0; i + 1 < length; i++) {
      yield (elementAt(i), elementAt(i + 1));
    }
  }
}

/// Extension on [Iterable] that provides a [tryMap] method.
extension IterableTryMap<T> on Iterable<T> {
  /// Maps each element using [f], catching exceptions and returning null for
  /// those elements.
  Iterable<U?> tryMap<U>(U Function(T) f) => map((e) {
    try {
      return f(e);
    } catch (_) {
      return null;
    }
  });
}

/// Extension on [Iterable] of [MapEntry] to filter and convert to [Map].
extension MapEntryIterableExtension<K, V> on Iterable<MapEntry<K, V>> {
  /// Filters entries by key and returns a new [Map].
  Map<K, V> whereKey(bool Function(K key) test) => {
    for (final entry in this)
      if (test(entry.key)) entry.key: entry.value,
  };
}

/// Extension on [Iterable] to zip elements with another iterable.
extension IterableZip<T> on Iterable<T> {
  /// Zips this iterable with [other].
  Iterable<(T, U)> zipWith<U>(Iterable<U> other) sync* {
    for (var i = 0; i < length && i < other.length; i++) {
      yield (elementAt(i), other.elementAt(i));
    }
  }

  /// Zips this iterable with [other] and includes the index.
  Iterable<(int, T, U)> zipWithIndexed<U>(Iterable<U> other) sync* {
    for (var i = 0; i < length && i < other.length; i++) {
      yield (i, elementAt(i), other.elementAt(i));
    }
  }
}
