/// Extension on [Map] to provide filtering and casting utilities.
extension MapExtensions<K, V> on Map<K, V> {
  /// Filters the map entries keeping only those whose keys are of type [U],
  /// and casts the resulting map's keys to [U].
  Map<U, V> whereKeyType<U>() => {
    for (final MapEntry(:key, :value) in entries)
      if (key is U) key: value,
  };

  /// Filters the map entries keeping only those whose values are of type [W],
  /// and casts the resulting map's values to [W].
  Map<K, W> whereValueType<W>() => {
    for (final MapEntry(:key, :value) in entries)
      if (value is W) key: value,
  };
}
