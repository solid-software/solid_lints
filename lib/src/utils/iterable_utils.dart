import 'package:collection/collection.dart';

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
