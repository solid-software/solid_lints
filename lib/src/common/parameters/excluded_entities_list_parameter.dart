import 'package:analyzer/dart/ast/ast.dart';

/// A model representing "exclude_entity" parameters for linting, defining
/// identifiers (classes, mixins, enums, extensions, extension_types) to be
/// ignored during analysis.
/// Supported entities:
///   - mixin
///   - extension
///   - extension_type
///   - enum
///
/// @docType String | List<String>
class ExcludedEntitiesListParameter {
  /// The parameter model
  final Set<String> excludedEntityNames;

  /// A common parameter key for analysis_options.yaml
  static const String excludeEntityKey = 'exclude_entity';

  /// Constructor for [ExcludedEntitiesListParameter] class
  ExcludedEntitiesListParameter({
    required this.excludedEntityNames,
  });

  /// Creates an [ExcludedEntitiesListParameter] from JSON.
  factory ExcludedEntitiesListParameter.fromJson(Map<String, Object?> json) {
    final raw = json[excludeEntityKey];
    if (raw is Iterable) {
      return ExcludedEntitiesListParameter(
        excludedEntityNames: raw.whereType<String>().toSet(),
      );
    } else if (raw is String) {
      return ExcludedEntitiesListParameter(
        excludedEntityNames: {raw},
      );
    }

    return ExcludedEntitiesListParameter(excludedEntityNames: {});
  }

  /// Returns whether the target node should be ignored during analysis.
  bool shouldIgnoreEntity(Declaration node) {
    if (excludedEntityNames.isEmpty) return false;

    if (node is MixinDeclaration && excludedEntityNames.contains('mixin')) {
      return true;
    } else if (node is EnumDeclaration &&
        excludedEntityNames.contains('enum')) {
      return true;
    } else if (node is ExtensionDeclaration &&
        excludedEntityNames.contains('extension')) {
      return true;
    } else if (node is ExtensionTypeDeclaration &&
        excludedEntityNames.contains('extension_type')) {
      return true;
    }

    return false;
  }
}
