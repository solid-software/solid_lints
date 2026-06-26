/// Sugar syntax helper to write extensions analogous to bool implies.
///
/// A truthy (!= [falsy]) value of [a] implies an equal value of [b].
bool objectImplies<T>(T a, T b, T falsy) => a == falsy || a == b;

/// Logical implication operation for booleans.
extension BoolImplies on bool {
  /// Logical implication operation.
  ///
  /// True implies that [other] is also true.
  // ignore: avoid_positional_boolean_parameters
  bool implies(bool other) => objectImplies(this, other, false);
}

/// Logical implication operation for strings.
extension StringImplies on String? {
  /// Logical implication operation.
  bool implies(String? other) => objectImplies(this, other, null);
}
