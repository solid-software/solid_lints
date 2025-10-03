import 'package:analyzer/dart/ast/ast.dart';
import 'package:collection/collection.dart';
import 'package:solid_lints/src/common/parameters/excluded_identifier_parameter.dart';

/// A model representing "exclude" parameters for linting, defining
/// identifiers (classes, methods, functions) to be ignored during analysis.
class ExcludedIdentifiersListParameter {
  /// A list of identifiers (classes, methods, functions) that should be
  /// excluded from the lint.
  final List<ExcludedIdentifierParameter> exclude;

  /// A common parameter key for analysis_options.yaml
  static const String excludeParameterName = 'exclude';

  /// Constructor for [ExcludedIdentifiersListParameter] model
  ExcludedIdentifiersListParameter({
    required this.exclude,
  });

  /// Method for creating from json data
  factory ExcludedIdentifiersListParameter.fromJson({
    required Iterable<dynamic> excludeList,
  }) {
    final exclude = <ExcludedIdentifierParameter>[];

    for (final item in excludeList) {
      if (item is Map) {
        exclude.add(ExcludedIdentifierParameter.fromJson(item));
      } else if (item is String) {
        exclude.add(
          ExcludedIdentifierParameter(
            declarationName: item,
          ),
        );
      }
    }
    return ExcludedIdentifiersListParameter(
      exclude: exclude,
    );
  }

  /// Method for creating from json data with default params
  factory ExcludedIdentifiersListParameter.defaultFromJson(
    Map<String, dynamic> json,
  ) {
    final excludeList =
        json[ExcludedIdentifiersListParameter.excludeParameterName]
            as Iterable? ??
        [];

    return ExcludedIdentifiersListParameter.fromJson(
      excludeList: excludeList,
    );
  }

  /// Returns whether the target node should be ignored during analysis.
  bool shouldIgnore(Declaration node) {
    final declarationName = node.declaredFragment?.name;

    final excludedItem = exclude.firstWhereOrNull(
      (e) {
        if (e.declarationName == declarationName) {
          return true;
        } else if (node is ClassDeclaration) {
          return e.className == declarationName;
        } else if (node is MethodDeclaration) {
          return e.methodName == declarationName;
        } else if (node is FunctionDeclaration) {
          return e.methodName == declarationName;
        }
        return false;
      },
    );

    if (excludedItem == null) return false;

    final className = excludedItem.className;

    if (className == null || node is! MethodDeclaration) {
      return true;
    } else {
      final classDeclaration = node.thisOrAncestorOfType<ClassDeclaration>();

      return classDeclaration != null &&
          classDeclaration.name.toString() == className;
    }
  }
}
