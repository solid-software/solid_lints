import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:solid_lints/src/lints/prefer_last/prefer_last_rule.dart';
import 'package:solid_lints/src/utils/types_utils.dart';

/// The AST visitor that will collect all Iterable access expressions
/// which can be replaced with .last
class PreferLastVisitor extends RecursiveAstVisitor<void> {
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

    final arg = node.argumentList.arguments.first;

    if (arg is BinaryExpression &&
        _isLastElementAccess(arg, target.toString())) {
      _rule.reportAtNode(node);
    }
  }

  @override
  void visitIndexExpression(IndexExpression node) {
    super.visitIndexExpression(node);

    final target = node.realTarget;

    if (!isListOrSubclass(target.staticType)) return;

    final index = node.index;

    if (index is BinaryExpression &&
        _isLastElementAccess(index, target.toString())) {
      _rule.reportAtNode(node);
    }
  }

  bool _isLastElementAccess(BinaryExpression expression, String targetName) {
    final right = expression.rightOperand;
    if (right is! IntegerLiteral || right.value != 1) return false;

    final isMinusExpression = expression.operator.type == TokenType.MINUS;
    if (!isMinusExpression) return false;

    final left = expression.leftOperand;
    final leftName = _getLeftOperandName(left);

    return leftName == '$targetName.length';
  }

  String? _getLeftOperandName(Expression expression) {
    if (expression is PrefixedIdentifier) {
      return expression.name;
    }

    /// Access target like map.keys.length is being reported as PropertyAccess
    /// expression this case will handle such cases
    if (expression is PropertyAccess) {
      if (expression.operator.type != TokenType.PERIOD) return null;

      return expression.toString();
    }

    return null;
  }
}
