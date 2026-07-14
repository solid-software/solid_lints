import 'package:solid_lints/src/common/parameters/excluded_identifiers_list_parameter.dart';

/// Configuration parameters for the avoid_duplicate_code rule.
class AvoidDuplicateCodeParameters {
  /// Minimum number of tokens in a function body or block to be considered
  /// for clone detection. Bodies/blocks shorter than this are ignored.
  final int minTokens;

  /// When `true`, literal values (strings, numbers, booleans) are excluded
  /// from the structural hash, making the check ignore literal differences.
  final bool ignoreLiterals;

  /// When `true`, local variable and parameter names are excluded
  /// from the structural hash, allowing detection of renamed variables
  /// (Type 2). Note that method, class, and field names are NOT ignored
  /// to prevent excessive false positives.
  final bool ignoreIdentifiers;

  /// When `true`, statement blocks (like if-blocks or loops) inside functions
  /// are also checked for duplication.
  final bool checkBlocks;

  /// A list of methods/functions that should be excluded from the lint.
  final ExcludedIdentifiersListParameter exclude;

  static const _defaultMinTokens = 50;

  static final _defaultExclude = ExcludedIdentifiersListParameter(
    exclude: const [],
  );

  /// Constructor for [AvoidDuplicateCodeParameters] model.
  const AvoidDuplicateCodeParameters({
    required this.minTokens,
    required this.ignoreLiterals,
    required this.ignoreIdentifiers,
    required this.checkBlocks,
    required this.exclude,
  });

  /// Empty [AvoidDuplicateCodeParameters] model with default values.
  factory AvoidDuplicateCodeParameters.empty() => AvoidDuplicateCodeParameters(
    minTokens: _defaultMinTokens,
    ignoreLiterals: false,
    ignoreIdentifiers: true,
    checkBlocks: true,
    exclude: _defaultExclude,
  );

  /// Creates parameters from JSON configuration.
  factory AvoidDuplicateCodeParameters.fromJson(Map<String, Object?> json) {
    return AvoidDuplicateCodeParameters(
      minTokens: json['min_tokens'] as int? ?? _defaultMinTokens,
      ignoreLiterals: json['ignore_literals'] as bool? ?? false,
      ignoreIdentifiers: json['ignore_identifiers'] as bool? ?? true,
      checkBlocks: json['check_blocks'] as bool? ?? true,
      exclude: ExcludedIdentifiersListParameter.defaultFromJson(json),
    );
  }

  /// Converts the parameters to a JSON-compatible Map.
  Map<String, Object?> toJson() => {
    'min_tokens': minTokens,
    'ignore_literals': ignoreLiterals,
    'ignore_identifiers': ignoreIdentifiers,
    'check_blocks': checkBlocks,
    'exclude': exclude.exclude.map((e) => e.toJson()).toList(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AvoidDuplicateCodeParameters &&
          other.minTokens == minTokens &&
          other.ignoreLiterals == ignoreLiterals &&
          other.ignoreIdentifiers == ignoreIdentifiers &&
          other.checkBlocks == checkBlocks;

  @override
  int get hashCode => Object.hash(
    minTokens,
    ignoreLiterals,
    ignoreIdentifiers,
    checkBlocks,
  );
}
