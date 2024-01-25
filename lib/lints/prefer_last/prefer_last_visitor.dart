import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:solid_lints/src/utils/types_utils.dart';

/// The AST visitor that will collect all Iterable access expressions
/// which can be replaced with .last
class PreferLastVisitor extends RecursiveAstVisitor<void> {
  final _expressions = <Expression>[];

  /// List of all Iterable access expressions
  Iterable<Expression> get expressions => _expressions;

  @override
  void visitMethodInvocation(MethodInvocation node) {
    super.visitMethodInvocation(node);

    final target = node.realTarget;

    if (isIterableOrSubclass(target?.staticType) &&
        node.methodName.name == 'elementAt') {
      final arg = node.argumentList.arguments.first;

      if (arg is BinaryExpression &&
          _isLastElementAccess(arg, target.toString())) {
        _expressions.add(node);
      }
    }
  }

  @override
  void visitIndexExpression(IndexExpression node) {
    super.visitIndexExpression(node);

    final target = node.realTarget;

    if (isListOrSubclass(target.staticType)) {
      final index = node.index;

      if (index is BinaryExpression &&
          _isLastElementAccess(index, target.toString())) {
        _expressions.add(node);
      }
    }
  }

  bool _isLastElementAccess(BinaryExpression expression, String targetName) {
    final left = expression.leftOperand;
    final right = expression.rightOperand;
    final leftName = _getLeftOperandName(left);

    if (right is! IntegerLiteral) return false;
    if (right.value != 1) return false;
    if (expression.operator.type != TokenType.MINUS) return false;

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
