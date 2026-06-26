/// Extension on [Iterable] that provides a [pairwise] method for grouping
/// elements.
extension IterablePairwise<T> on Iterable<T> {
  /// Returns an iterable of overlapping pairs of elements.
  /// For example, `[1, 2, 3].pairwise()` returns `[(1, 2), (2, 3)]`.
  Iterable<(T, T)> pairwise() sync* {
    final iterator = this.iterator;
    if (!iterator.moveNext()) return;

    var previous = iterator.current;
    while (iterator.moveNext()) {
      yield (previous, iterator.current);
      previous = iterator.current;
    }
  }
}
