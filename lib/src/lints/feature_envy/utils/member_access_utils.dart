import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:solid_lints/src/lints/feature_envy/models/project_class_cache.dart';
import 'package:solid_lints/src/utils/node_utils.dart';
import 'package:solid_lints/src/utils/types_utils.dart';

/// Utility methods for analyzing member accesses within the feature envy lint.
abstract final class MemberAccessUtils {
  /// Resolves the base element of a member access target expression.
  static Element? resolveTargetElement(
    Expression? target, {
    required bool isPatternField,
  }) {
    if (isPatternField || target == null) return null;

    final baseElement = switch (target.unwrapTarget) {
      ExtensionOverride(:final argumentList) =>
        argumentList
            .arguments
            .firstOrNull
            ?.argumentExpression
            .staticType
            ?.element,
      final expr => expr?.staticType?.element,
    };

    return switch (baseElement?.resolveTypeParameter) {
      ExtensionElement(:final extendedType) =>
        extendedType.element?.resolveTypeParameter,
      final resolved => resolved,
    };
  }

  /// Checks if the access to [c] is considered internal to [currentClass].
  static bool isInternalAccess(
    Expression? target,
    InterfaceElement c, {
    required InterfaceElement currentClass,
    bool isPatternField = false,
  }) =>
      currentClass.isSameOrSubclassOf(c) &&
      (target != null || !isPatternField) &&
      switch (target?.unwrapTarget) {
        ExtensionOverride(:final argumentList) =>
          argumentList
                  .arguments
                  .firstOrNull
                  ?.argumentExpression
                  .unwrapTarget
                  .isThisOrSuper ??
              false,
        final expr => expr.isThisOrSuperOrNull,
      };

  /// Finds the highest level access expression that starts with [node].
  static Expression getAccessExpression(SimpleIdentifier node) =>
      findAccessExpression(node, node.parent);

  /// Recursively finds the top-most expression of an access.
  static Expression findAccessExpression(Expression child, AstNode? parent) =>
      switch (parent) {
        ParenthesizedExpression(:final expression) when expression == child =>
          findAccessExpression(parent, parent.parent),
        PropertyAccess(:final propertyName, :final target)
            when propertyName == child && target.unwrapTarget.isThisOrSuper =>
          findAccessExpression(parent, parent.parent),
        _ => child,
      };

  /// Determines if [node] is the target of an access to an external member.
  static bool isTargetOfExternalAccess(
    SimpleIdentifier node, {
    required InterfaceElement currentClass,
    required ProjectClassCache projectClassCache,
  }) {
    final enclosing = node.element?.enclosingInterface;
    if (enclosing == null || !currentClass.isSameOrSubclassOf(enclosing)) {
      return false;
    }

    final expr = getAccessExpression(node);

    bool isExternal(Element? e) => isExternalMember(
      e,
      currentClass: currentClass,
      projectClassCache: projectClassCache,
    );

    return switch (expr.parent) {
      MethodInvocation(:final target, :final methodName) when target == expr =>
        isExternal(methodName.element),
      PrefixedIdentifier(:final prefix, :final identifier)
          when prefix == expr =>
        isExternal(identifier.element),
      PropertyAccess(:final target, :final propertyName) when target == expr =>
        isExternal(propertyName.element),
      CascadeExpression(:final target, :final cascadeSections)
          when target == expr =>
        cascadeSections.any((s) => isExternal(s.memberElement)),
      _ => false,
    };
  }

  /// Determines if [element] represents a member of an external class.
  static bool isExternalMember(
    Element? element, {
    required InterfaceElement currentClass,
    required ProjectClassCache projectClassCache,
  }) => switch (element?.enclosingInterface) {
    final enclosing? =>
      !currentClass.isSameOrSubclassOf(enclosing) &&
          !enclosing.isDataClass &&
          projectClassCache.isProjectClass(enclosing),
    _ => false,
  };
}
