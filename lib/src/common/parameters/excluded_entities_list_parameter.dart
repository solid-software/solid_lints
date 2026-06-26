import 'package:analyzer/dart/ast/ast.dart';

/// A model representing "exclude_entity" parameters for linting, defining
/// identifiers (classes, mixins, enums, extensions, extension_types) to be ignored during
/// analysis.
/// Supported entities:
///   - mixin
///   - extension
///   - extension_type
///   - enum
class ExcludedEntitiesListParameter {
  /// The parameter model
  final Set<String> excludedEntityNames;

  /// A common parameter key for analysis_options.yaml
  static const String excludeEntityKey = 'exclude_entity';

  /// Constructor for [ExcludedEntitiesListParameter] class
  ExcludedEntitiesListParameter({
    required this.excludedEntityNames,
  });

  /// Method for creating from json data
  factory ExcludedEntitiesListParameter.fromJson(Map<String, Object?> json) {
    final excludedEntities = json['exclude_entity'];
    if (excludedEntities is Iterable) {
      return ExcludedEntitiesListParameter(
        excludedEntityNames: excludedEntities.cast<String>().toSet(),
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
