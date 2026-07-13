/// A custom implementation of the Jenkins One-at-a-Time hash algorithm.
///
/// This incrementally computes a hash without allocating large strings,
/// significantly reducing GC pressure during tree traversal.
class JenkinsHasher {
  int _hash = 0;

  /// Resets the hash to its initial state.
  void reset() {
    _hash = 0;
  }

  /// Adds a single 32-bit integer [value] to the hash.
  void add(int value) {
    _hash = 0x1fffffff & (_hash + value);
    _hash = 0x1fffffff & (_hash + ((0x0007ffff & _hash) << 10));
    _hash = _hash ^ (_hash >> 6);
  }

  /// Adds all code units of [value] to the hash.
  void addString(String value) {
    for (var i = 0; i < value.length; i++) {
      add(value.codeUnitAt(i));
    }
  }

  /// Finalizes and returns the computed hash.
  int get hash {
    var h = _hash;
    h = 0x1fffffff & (h + ((0x03ffffff & h) << 3));
    h = h ^ (h >> 11);
    h = 0x1fffffff & (h + ((0x00003fff & h) << 15));
    return h;
  }
}
