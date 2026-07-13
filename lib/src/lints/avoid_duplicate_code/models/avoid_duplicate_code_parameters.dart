import 'package:solid_lints/src/common/parameters/excluded_identifier_parameter.dart';
import 'package:solid_lints/src/common/parameters/excluded_identifiers_list_parameter.dart';

/// Configuration parameters for the avoid_duplicate_code rule.
class AvoidDuplicateCodeParameters {
  /// Minimum number of tokens in a function body or block to be considered
  /// for clone detection. Bodies/blocks shorter than this are ignored.
  final int minTokens;

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

  static const _defaultMinTokens = 50;

  static final _defaultExclude = ExcludedIdentifiersListParameter(
    exclude: const [
      ExcludedIdentifierParameter(methodName: 'initState'),
      ExcludedIdentifierParameter(methodName: 'dispose'),
      ExcludedIdentifierParameter(methodName: 'didChangeDependencies'),
      ExcludedIdentifierParameter(methodName: 'didUpdateWidget'),
      ExcludedIdentifierParameter(methodName: 'build'),
    ],
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
    checkBlocks: false,
    exclude: _defaultExclude,
  );

  /// Creates parameters from JSON configuration.
  factory AvoidDuplicateCodeParameters.fromJson(Map<String, Object?> json) {
    final baseExclude = ExcludedIdentifiersListParameter.defaultFromJson(json);
    final combinedExclude = ExcludedIdentifiersListParameter(
      exclude: [
        ..._defaultExclude.exclude,
        ...baseExclude.exclude,
      ],
    );

    return AvoidDuplicateCodeParameters(
      minTokens: json['min_tokens'] as int? ?? _defaultMinTokens,
      ignoreLiterals:
          json['ignore_literals'] as bool? ??
          json['ignore_literal_values'] as bool? ??
          false,
      ignoreIdentifiers: json['ignore_identifiers'] as bool? ?? true,
      checkBlocks: json['check_blocks'] as bool? ?? false,
      exclude: combinedExclude,
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
}
