import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:solid_lints/src/lints/use_nearest_context/use_nearest_context_rule.dart';
import 'package:solid_lints/src/lints/use_nearest_context/utils/use_nearest_context_utils.dart';
import 'package:solid_lints/src/utils/types_utils.dart';

/// A visitor for [UseNearestContextRule].
class UseNearestContextVisitor extends SimpleAstVisitor<void> {
  final UseNearestContextRule _rule;

  /// Creates a new instance of [UseNearestContextVisitor].
  UseNearestContextVisitor(this._rule);

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    if (!isBuildContext(node.staticType)) return;
    if (_isPropertyOfOtherObject(node)) return;

    final closestBuildContext = findClosestBuildContext(node);
    if (closestBuildContext == null) return;
    if (closestBuildContext.name?.lexeme != node.name) {
      if (_isDeclaredInNearestScope(node, closestBuildContext)) return;

      _rule.reportAtNode(node);
    }
  }

  @override
  void visitThisExpression(ThisExpression node) {
    if (!isBuildContext(node.staticType)) return;

    final closestBuildContext = findClosestBuildContext(node);
    if (closestBuildContext == null) return;

    _rule.reportAtNode(node);
  }

  /// Returns `true` if [node] is a property accessed on another object
  /// (e.g. `state.context`), but not on `this` (e.g. `this.context`).
  bool _isPropertyOfOtherObject(SimpleIdentifier node) {
    final parent = node.parent;
    if (parent is PrefixedIdentifier && node == parent.identifier) {
      return true;
    }
    if (parent is PropertyAccess && node == parent.propertyName) {
      var target = parent.target;
      while (target is ParenthesizedExpression) {
        target = target.expression;
      }
      return target is! ThisExpression && target is! SuperExpression;
    }
    return false;
  }

  /// Returns `true` if [node] refers to a variable declared inside the body
  /// of the function that owns [closestParam] (i.e. a local variable
  /// in the same scope, like `final localCtx = innerContext;`).
  bool _isDeclaredInNearestScope(
    SimpleIdentifier node,
    SimpleFormalParameter closestParam,
  ) {
    final element = node.element;
    if (element is! LocalVariableElement) return false;

    final nearestFunction = closestParam.parent?.parent;
    if (nearestFunction is! FunctionExpression) return false;

    final body = nearestFunction.body;
    final declOffset = element.firstFragment.nameOffset;
    if (declOffset == null) return false;
    return declOffset >= body.offset && declOffset < body.end;
  }
}
