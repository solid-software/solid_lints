/// A data model class that represents the "prefer conditional expressions"
/// input parameters.
class PreferConditionalExpressionsParameters {
  static const _ignoreNestedConfig = 'ignore_nested';

  /// Determines whether to ignore nested if statements:
  ///
  /// ```dart
  ///  // Allowed if ignore_nested flag is enabled
  ///  if (1 > 0) {
  ///    _result = 1 > 2 ? 2 : 1;
  ///  } else {
  ///    _result = 0;
  ///  }
  /// ```
  final bool ignoreNested;

  /// Constructor for [PreferConditionalExpressionsParameters] model
  const PreferConditionalExpressionsParameters({
    required this.ignoreNested,
  });

  /// Method for creating from json data
  factory PreferConditionalExpressionsParameters.fromJson(
    Map<String, Object?> json,
  ) => PreferConditionalExpressionsParameters(
    ignoreNested: json[_ignoreNestedConfig] as bool? ?? false,
  );
}
