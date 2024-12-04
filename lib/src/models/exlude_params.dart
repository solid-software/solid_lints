import 'package:analyzer/dart/ast/ast.dart';
import 'package:collection/collection.dart';
import 'package:solid_lints/src/models/exclude_rule.dart';

/// A data model class that represents the "avoid returning widgets" input
/// parameters.
class ExcludeParameters {
  /// A list of methods that should be excluded from the lint.
  final List<ExcludeRule> exclude;

  /// Constructor for [ExcludeParameters] model
  ExcludeParameters({
    required this.exclude,
  });

  /// Method for creating from json data
  factory ExcludeParameters.fromJson({
    required Iterable<dynamic> excludeList,
  }) {
    final exclude = <ExcludeRule>[];

    for (final item in excludeList) {
      if (item is Map) {
        exclude.add(ExcludeRule.fromJson(item));
      }
    }
    return ExcludeParameters(
      exclude: exclude,
    );
  }

  /// Method to define ignoring
  bool shouldIgnore(Declaration node) {
    final methodName = node.declaredElement?.name;

    final excludedItem =
        exclude.firstWhereOrNull((e) => e.methodName == methodName);

    if (excludedItem == null) return false;

    final className = excludedItem.className;

    if (className == null || node is! MethodDeclaration) {
      return true;
    } else {
      final classDeclaration = node.thisOrAncestorOfType<ClassDeclaration>();

      if (classDeclaration == null) return false;

      return classDeclaration.name.toString() == className;
    }
  }
}
