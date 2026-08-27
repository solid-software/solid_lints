import 'package:solid_lints/src/common/parameters/excluded_identifiers_list_parameter.dart';

/// Configuration parameters for the avoid_duplicate_code rule.
class AvoidDuplicateCodeParameters {
  /// Minimum number of tokens in a function body or block required for it to
  /// be included in clone detection. Shorter bodies/blocks are ignored.
  ///
  /// :::note What is a Token?
  /// The smallest indivisible syntactic unit of code emitted by the compiler's
  /// lexer (keywords `final`, `if`, `switch`; identifiers; operators `=`, `=>`;
  /// punctuation `{`, `}`, `;` and literals).
  /// :::
  ///
  /// Considering the modern and concise syntax of Dart 3+ (switch expressions,
  /// pattern matching, record destructuring), the optimal default threshold
  /// was determined to be **30 tokens** (approximately 4-6 lines of meaningful
  /// code). This automatically filters out trivial single-line expressions and
  /// focuses exclusively on substantial logic blocks.
  ///
  /// ##### Example 1: Less than 30 tokens (Ignored): 26 tokens
  /// A concise switch expression in Dart 3 syntax contains **26 tokens** and
  /// is ignored:
  /// ```dart
  /// Color getShapeColor(Shape shape) => switch (shape) { // 6 tokens
  ///       Circle(:final color) => color,                 // 9 tokens
  ///       Square(:final color) => color,                 // 9 tokens
  ///     };                                               // 2 tokens
  /// ```
  ///
  /// ##### Example 2: 30+ tokens (Checked for duplicates): 34 tokens
  /// A function with record destructuring and pattern matching in Dart 3 syntax
  /// contains **34 tokens** and is checked for duplicates:
  /// ```dart
  /// String formatUserRole(Object user) => switch (user) {   // 6 tokens
  ///       User(isAdmin: true, isVerified: true) => 'Admin', // 13 tokens
  ///       User(isVerified: true) => 'User',                 // 9 tokens
  ///       _ => 'Guest User',                                // 4 tokens
  ///     };                                                  // 2 tokens
  /// ```
  final int minTokens;

  /// A list of methods/functions that should be excluded from clone detection.
  final ExcludedIdentifiersListParameter exclude;

  static const _defaultMinTokens = 30;

  static final _defaultExclude = ExcludedIdentifiersListParameter(
    exclude: const [],
  );

  /// Constructor for [AvoidDuplicateCodeParameters] model.
  const AvoidDuplicateCodeParameters({
    required this.minTokens,
    required this.exclude,
  });

  /// Empty [AvoidDuplicateCodeParameters] model with default values.
  factory AvoidDuplicateCodeParameters.empty() => AvoidDuplicateCodeParameters(
    minTokens: _defaultMinTokens,
    exclude: _defaultExclude,
  );

  /// Creates parameters from JSON configuration.
  factory AvoidDuplicateCodeParameters.fromJson(Map<String, Object?> json) =>
      AvoidDuplicateCodeParameters(
        minTokens: json['min_tokens'] as int? ?? _defaultMinTokens,
        exclude: ExcludedIdentifiersListParameter.defaultFromJson(json),
      );

  /// Converts the parameters to a JSON-compatible Map.
  Map<String, Object?> toJson() => {
    'min_tokens': minTokens,
    'exclude': exclude.exclude.map((e) => e.toJson()).toList(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AvoidDuplicateCodeParameters &&
          other.minTokens == minTokens &&
          other.exclude == exclude;

  @override
  int get hashCode => Object.hash(
    minTokens,
    exclude,
  );
}
