import 'package:solid_lints/src/common/parameters/excluded_identifiers_list_parameter.dart';

/// Configuration parameters for the avoid_duplicate_code rule.
class AvoidDuplicateCodeParameters {
  /// Minimum number of statements in a function body or block to be considered
  /// for clone detection. Bodies/blocks shorter than this are ignored.
  final int minStatements;

  /// When `true`, literal values (strings, numbers, booleans) are excluded
  /// from the structural hash, making the check ignore literal differences.
  final bool ignoreLiterals;

  /// When `true`, variable and method names (identifiers) are excluded
  /// from the structural hash, allowing detection of renamed variables
  /// (Type 2).
  final bool ignoreIdentifiers;

  /// When `true`, statement blocks (like if-blocks or loops) inside functions
  /// are also checked for duplication.
  final bool checkBlocks;

  /// A list of methods/functions that should be excluded from the lint.
  final ExcludedIdentifiersListParameter exclude;

  static const _defaultMinStatements = 10;

  /// Constructor for [AvoidDuplicateCodeParameters] model.
  const AvoidDuplicateCodeParameters({
    required this.minStatements,
    required this.ignoreLiterals,
    required this.ignoreIdentifiers,
    required this.checkBlocks,
    required this.exclude,
  });

  /// Empty [AvoidDuplicateCodeParameters] model with default values.
  factory AvoidDuplicateCodeParameters.empty() =>
      AvoidDuplicateCodeParameters(
        minStatements: _defaultMinStatements,
        ignoreLiterals: false,
        ignoreIdentifiers: true,
        checkBlocks: false,
        exclude: ExcludedIdentifiersListParameter(exclude: []),
      );

  /// Creates parameters from JSON configuration.
  factory AvoidDuplicateCodeParameters.fromJson(Map<String, Object?> json) =>
      AvoidDuplicateCodeParameters(
        minStatements:
            json['min_statements'] as int? ?? _defaultMinStatements,
        ignoreLiterals:
            json['ignore_literals'] as bool? ??
            json['ignore_literal_values'] as bool? ??
            false,
        ignoreIdentifiers:
            json['ignore_identifiers'] as bool? ?? true,
        checkBlocks:
            json['check_blocks'] as bool? ?? false,
        exclude: ExcludedIdentifiersListParameter.defaultFromJson(json),
      );
}
