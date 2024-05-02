import 'package:analyzer/dart/ast/ast.dart';
import 'package:solid_lints/src/models/ignored_entities_model/ignored_entity.dart';

/// Manages a list of entities (functions/methods/classes) that should be
/// excluded from a lint rule.
///
/// Example config:
/// ```yaml
/// custom_lint:
///   rules:
///     - <rule_name>:
///       exclude:
///         # excludes a matching method in a matching class
///         - method_name: excludeMethod
///           class_name: ExcludeClass
///         # excludes a matching method anywhere
///         - method_name: excludeFunction
///         # excludes all methods within a matching class
///         - class_name: ExcludeEntireClass
/// ```
class IgnoredEntitiesModel {
  ///
  const IgnoredEntitiesModel._({required this.entities});

  ///
  factory IgnoredEntitiesModel.fromJson(Map<dynamic, dynamic> json) {
    final entities = <IgnoredEntity>[];
    final excludeList = json['exclude'] as Iterable? ?? [];
    for (final item in excludeList) {
      if (item is Map) {
        entities.add(IgnoredEntity.fromJson(item));
      }
    }
    return IgnoredEntitiesModel._(entities: entities);
  }

  /// The entities to be ignored
  final List<IgnoredEntity> entities;

  /// Checks if the entire class should be ignored.
  /// Doesn't match if the config specifies a specific function within the class
  bool isIgnoredClass(AstNode node) {
    final classNode = node.thisOrAncestorOfType<ClassDeclaration>();
    if (classNode == null) {
      return false;
    }

    final className = classNode.name.toString();

    return entities.any((element) {
      return element.functionName == null && element.className == className;
    });
  }

  /// Checks if the given method/function should be ignored.
  bool isIgnoredMethod(AstNode node) {
    final methodNode = node.thisOrAncestorOfType<Declaration>();
    if (methodNode == null) {
      return false;
    }

    final methodName = methodNode.declaredElement?.name;

    return entities.any((entity) {
      if (entity.functionName != methodName) {
        return false;
      }

      if (entity.className == null) {
        return true;
      }

      final matchingClass = methodNode.thisOrAncestorMatching((node) {
        if (node case final ClassDeclaration classNode) {
          return classNode.name.toString() == entity.className;
        }

        return false;
      });

      return matchingClass != null;
    });
  }
}
