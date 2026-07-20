/// A dictionary that maps a key to a set of values.
class SetDictionary<K, V> {
  final _map = <K, Set<V>>{};

  /// Adds a [value] to the set associated with the [key].
  void add(K key, V value) {
    _map.putIfAbsent(key, () => {}).add(value);
  }

  /// Removes a [value] from the set associated with the [key].
  ///
  /// If the set becomes empty after removing the value, the [key] is removed
  /// from the dictionary.
  void remove(K key, V value) {
    final set = _map[key];
    if (set == null) return;

    set.remove(value);
    if (set.isEmpty) {
      _map.remove(key);
    }
  }

  /// Returns the set of values associated with the [key], or `null` if the
  /// key is not in the dictionary.
  Set<V>? operator [](K key) => _map[key];

  /// Removes all keys and values from the dictionary.
  void clear() {
    _map.clear();
  }
}
