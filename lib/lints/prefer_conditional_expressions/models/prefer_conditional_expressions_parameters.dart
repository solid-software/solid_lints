/// A data model class that represents the "prefer conditional expressions"
/// input parameters.
class PreferConditionalExpressionsParameters {
  static const _ignoreNestedConfig = 'ignore_nested';

  /// Should rule ignore nested if statements
  final bool ignoreNested;

  /// Constructor for [PreferConditionalExpressionsParameters] model
  const PreferConditionalExpressionsParameters({
    required this.ignoreNested,
  });

  /// Method for creating from json data
  factory PreferConditionalExpressionsParameters.fromJson(
    Map<String, Object?> json,
  ) =>
      PreferConditionalExpressionsParameters(
        ignoreNested: json[_ignoreNestedConfig] as bool? ?? false,
      );
}
