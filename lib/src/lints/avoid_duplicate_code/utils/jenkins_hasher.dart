/// A custom implementation of the Jenkins One-at-a-Time hash algorithm.
///
/// This incrementally computes a hash without allocating large strings,
/// significantly reducing GC pressure during tree traversal.
class JenkinsHasher {
  static const _hashMask = 0x1fffffff;
  static const _shift10Mask = 0x0007ffff;
  static const _shift3Mask = 0x03ffffff;
  static const _shift15Mask = 0x00003fff;

  int _hash = 0;

  /// Resets the hash to its initial state.
  void reset() => _hash = 0;

  /// Adds a single 32-bit integer [value] to the hash.
  void add(int value) {
    _hash = _mix(_hashMask & (_hash + value), _shift10Mask, 10);
    _hash ^= _hash >> 6;
  }

  /// Adds all code units of [value] to the hash.
  void addString(String value) => value.codeUnits.forEach(add);

  /// Finalizes and returns the computed hash.
  int get hash {
    final h = _mix(_hash, _shift3Mask, 3);
    return _mix(h ^ (h >> 11), _shift15Mask, 15);
  }

  static int _mix(int hash, int shiftMask, int shiftAmount) =>
      _hashMask & (hash + ((shiftMask & hash) << shiftAmount));
}
