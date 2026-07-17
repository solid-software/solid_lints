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
    final unwrapped = target?.unwrapTarget;
    final baseElement = switch (unwrapped) {
      _ when isPatternField => null,
      ExtensionOverride(
        argumentList: ArgumentList(arguments: [final firstArg, ...]),
      ) =>
        firstArg.staticType?.element,
      final expr? => expr.staticType?.element,
      _ => null,
    };

    var resolved = baseElement?.resolveTypeParameter;
    if (resolved case ExtensionElement(:final extendedType)) {
      resolved = extendedType.element?.resolveTypeParameter;
    }

    return resolved;
  }

  /// Checks if the access to [c] is considered internal to [currentClass].
  static bool isInternalAccess(
    Expression? target,
    InterfaceElement c, {
    required InterfaceElement currentClass,
    bool isPatternField = false,
  }) {
    if (!currentClass.isSameOrSubclassOf(c)) return false;
    if (target == null && isPatternField) return false;

    final unwrapped = target?.unwrapTarget;

    return switch (unwrapped) {
      ExtensionOverride(
        argumentList: ArgumentList(arguments: [final firstArg, ...]),
      ) =>
        firstArg.unwrapTarget.isThisOrSuper,
      _ => unwrapped.isThisOrSuperOrNull,
    };
  }

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
    if (node.parent == null) return false;

    final element = node.element;
    if (element == null) return false;

    final enclosing = element.enclosingInterface;
    if (enclosing == null || !currentClass.isSameOrSubclassOf(enclosing)) {
      return false;
    }

    final expr = getAccessExpression(node);
    final exprParent = expr.parent;
    if (exprParent == null) return false;

    return switch (exprParent) {
      MethodInvocation(:final target, :final methodName) when target == expr =>
        isExternalMember(
          methodName.element,
          currentClass: currentClass,
          projectClassCache: projectClassCache,
        ),
      PrefixedIdentifier(:final prefix, :final identifier)
          when prefix == expr =>
        isExternalMember(
          identifier.element,
          currentClass: currentClass,
          projectClassCache: projectClassCache,
        ),
      PropertyAccess(:final target, :final propertyName) when target == expr =>
        isExternalMember(
          propertyName.element,
          currentClass: currentClass,
          projectClassCache: projectClassCache,
        ),
      CascadeExpression(:final target, :final cascadeSections)
          when target == expr =>
        cascadeSections.any(
          (s) => isExternalMember(
            s.memberElement,
            currentClass: currentClass,
            projectClassCache: projectClassCache,
          ),
        ),
      _ => false,
    };
  }

  /// Determines if [element] represents a member of an external class.
  static bool isExternalMember(
    Element? element, {
    required InterfaceElement currentClass,
    required ProjectClassCache projectClassCache,
  }) {
    final enclosing = element?.enclosingInterface;
    if (enclosing == null) return false;

    return !currentClass.isSameOrSubclassOf(enclosing) &&
        projectClassCache.isProjectClass(enclosing) &&
        !enclosing.isDataClass;
  }
}
