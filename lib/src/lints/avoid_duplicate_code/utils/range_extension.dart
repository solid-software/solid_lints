/// Extension on an (offset, length) record to check if it is strictly
/// within another parent (offset, length) range.
extension RangeExtension on (int, int) {
  /// Returns `true` if this range is strictly inside the [parent] range
  /// (meaning it is within the bounds but not exactly equal to the parent).
  bool isStrictlyWithin((int, int) parent) {
    return this.$1 >= parent.$1 &&
        (this.$1 + this.$2) <= (parent.$1 + parent.$2) &&
        !(this.$1 == parent.$1 && this.$2 == parent.$2);
  }
}
