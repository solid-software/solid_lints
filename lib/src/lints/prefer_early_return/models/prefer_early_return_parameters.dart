/// A data model class that represents the "prefer early return"
/// input parameters.
class PreferEarlyReturnParameters {
  static const _maximumStatementsConfig = 'maximum_statements';
  static const _ignoreIfCaseConfig = 'ignore_if_case';

  static const _defaultMaximumStatements = 1;
  static const _defaultIgnoreIfCase = true;

  /// The maximum number of statements allowed inside an `if` block before
  /// triggering the lint. If the number of statements does not exceed this
  /// threshold, the analysis is skipped.
  final int maximumStatements;

  /// Whether to ignore `if-case` pattern matching statements.
  final bool ignoreIfCase;

  /// Constructor for [PreferEarlyReturnParameters] model.
  const PreferEarlyReturnParameters({
    required this.maximumStatements,
    required this.ignoreIfCase,
  });

  /// Empty [PreferEarlyReturnParameters] model with default values.
  factory PreferEarlyReturnParameters.empty() =>
      const PreferEarlyReturnParameters(
        maximumStatements: _defaultMaximumStatements,
        ignoreIfCase: _defaultIgnoreIfCase,
      );

  /// Method for creating [PreferEarlyReturnParameters] from json data.
  factory PreferEarlyReturnParameters.fromJson(
    Map<String, Object?> json,
  ) => PreferEarlyReturnParameters(
    maximumStatements:
        json[_maximumStatementsConfig] as int? ?? _defaultMaximumStatements,
    ignoreIfCase: json[_ignoreIfCaseConfig] as bool? ?? _defaultIgnoreIfCase,
  );
}
