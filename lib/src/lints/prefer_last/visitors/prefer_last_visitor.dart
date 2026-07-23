import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:solid_lints/src/lints/prefer_last/prefer_last_rule.dart';
import 'package:solid_lints/src/utils/types_utils.dart';

/// The AST visitor that will collect all Iterable access expressions
/// which can be replaced with .last
class PreferLastVisitor extends RecursiveAstVisitor<void> {
  static const _lengthGetterName = 'length';

  final PreferLastRule _rule;

  /// Creates a new instance of [PreferLastVisitor]
  PreferLastVisitor(this._rule);

  @override
  void visitMethodInvocation(MethodInvocation node) {
    super.visitMethodInvocation(node);

    final target = node.realTarget;
    final isIterable = isIterableOrSubclass(target?.staticType);
    final isElementAt = node.methodName.name == 'elementAt';

    if (!isIterable || !isElementAt) return;

    final arg = node.argumentList.arguments.firstOrNull;

    if (arg is BinaryExpression && _isLastElementAccess(arg, target)) {
      _rule.reportAtNode(node);
    }
  }

  @override
  void visitIndexExpression(IndexExpression node) {
    super.visitIndexExpression(node);

    final target = node.realTarget;

    if (!isListOrSubclass(target.staticType)) return;

    final index = node.index;

    if (index is BinaryExpression && _isLastElementAccess(index, target)) {
      _rule.reportAtNode(node);
    }
  }

  bool _isLastElementAccess(BinaryExpression expression, Expression? target) {
    final right = expression.rightOperand;
    if (right is! IntegerLiteral || right.value != 1) return false;

    if (expression.operator.type != TokenType.MINUS) return false;
    if (target == null) return false;

    return _isLengthOfTarget(expression.leftOperand, target);
  }

  bool _isLengthOfTarget(Expression expression, Expression target) {
    final lengthReceiver = switch (expression) {
      PropertyAccess(
        propertyName: SimpleIdentifier(name: _lengthGetterName),
        operator: Token(type: TokenType.PERIOD),
        :final target,
      ) =>
        target,
      PrefixedIdentifier(
        prefix: final prefix,
        identifier: SimpleIdentifier(name: _lengthGetterName),
      ) =>
        prefix,
      _ => null,
    };

    if (lengthReceiver == null) return false;

    return _referencesSameTarget(lengthReceiver, target);
  }

  bool _referencesSameTarget(
    Expression lengthReceiver,
    Expression accessTarget,
  ) {
    final normalizedLengthReceiver = _unwrapExpression(lengthReceiver);
    final normalizedAccessTarget = _unwrapExpression(accessTarget);

    if (normalizedLengthReceiver is Identifier &&
        normalizedAccessTarget is Identifier) {
      return normalizedLengthReceiver.element?.id ==
          normalizedAccessTarget.element?.id;
    }

    return normalizedLengthReceiver.toString() ==
        normalizedAccessTarget.toString();
  }

  Expression _unwrapExpression(Expression expression) {
    return switch (expression) {
      PostfixExpression(
        :final operand,
        operator: Token(type: TokenType.BANG),
      ) =>
        _unwrapExpression(operand),

      ParenthesizedExpression(:final expression) => _unwrapExpression(
        expression,
      ),

      _ => expression,
    };
  }
}
