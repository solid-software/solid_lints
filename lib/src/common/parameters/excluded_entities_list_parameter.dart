import 'package:analyzer/dart/ast/ast.dart';

/// A model representing "exclude_entity" parameters for linting, defining
/// identifiers (classes, mixins, enums, extensions) to be ignored during
/// analysis.
class ExcludedEntitiesListParameters {
  /// The parameter model
  final List<String> excludedEntityNames;

  /// A common parameter key for analysis_options.yaml
  static const String excludeEntityKey = 'exclude_entity';

  /// Constructor for [ExcludedEntitiesListParameters] class
  ExcludedEntitiesListParameters({
    required this.excludedEntityNames,
  });

  /// Method for creating from json data
  factory ExcludedEntitiesListParameters.fromJson(Map<String, dynamic> json) {
    final raw = json['exclude_entity'];
    if (raw is List) {
      return ExcludedEntitiesListParameters(
        excludedEntityNames: List<String>.from(raw),
      );
    }
    return ExcludedEntitiesListParameters(
      excludedEntityNames: [],
    );
  }

  /// Returns whether the target node should be ignored during analysis.
  bool shouldIgnoreEntity(Declaration node) {
    if (excludedEntityNames.isEmpty) return false;

    if (node is ClassDeclaration && excludedEntityNames.contains('class')) {
      return true;
    } else if (node is MixinDeclaration &&
        excludedEntityNames.contains('mixin')) {
      return true;
    } else if (node is EnumDeclaration &&
        excludedEntityNames.contains('enum')) {
      return true;
    } else if (node is ExtensionDeclaration &&
        excludedEntityNames.contains('extension')) {
      return true;
    }

    return false;
  }
}
