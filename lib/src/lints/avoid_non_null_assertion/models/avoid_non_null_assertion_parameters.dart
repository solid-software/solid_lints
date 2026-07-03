/// A data model class that represents the "avoid non null assertion" input
/// parameters.
class AvoidNonNullAssertionParameters {
  /// Types that would be ignored by avoid-non-null-assertion rule
  ///
  /// Example:
  ///
  /// ```yaml
  /// plugins:
  ///   solid_lints:
  ///     diagnostics:
  ///       avoid_non_null_assertion:
  ///         ignored_types:
  ///           - IMap
  /// ```
  ///
  /// ```dart
  /// IMap<String, String> map;
  /// map['key']!; // OK
  /// ```
  final Set<String> ignoredTypes;

  /// Constructor for [AvoidNonNullAssertionParameters] model
  const AvoidNonNullAssertionParameters({
    required this.ignoredTypes,
  });

  /// Empty [AvoidNonNullAssertionParameters] model, ignores nothing.
  factory AvoidNonNullAssertionParameters.empty() =>
      const AvoidNonNullAssertionParameters(
        ignoredTypes: {},
      );

  /// Method for creating from json data
  factory AvoidNonNullAssertionParameters.fromJson(Map<String, Object?> json) {
    final raw = json['ignored_types'];
    final excludeList = switch (raw) {
      Iterable() => raw.whereType<String>().toSet(),
      Map() || String() => {raw.toString()},
      _ => const <String>{},
    };

    return AvoidNonNullAssertionParameters(
      ignoredTypes: excludeList,
    );
  }
}
