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
