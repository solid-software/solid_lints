import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:solid_lints/utils/types_utils.dart';

/// The AST visitor that will collect all Iterable access expressions
/// which can be replaced with .first
class PreferFirstVisitor extends RecursiveAstVisitor<void> {
  final _expressions = <Expression>[];

  /// List of all Iterable access expressions
  Iterable<Expression> get expressions => _expressions;

  @override
  void visitMethodInvocation(MethodInvocation node) {
    super.visitMethodInvocation(node);
    final isIterable = isIterableOrSubclass(node.realTarget?.staticType);
    final isElementAt = node.methodName.name == 'elementAt';

    if (isIterable && isElementAt) {
      final arg = node.argumentList.arguments.first;

      if (arg is IntegerLiteral && arg.value == 0) {
        _expressions.add(node);
      }
    }
  }

  @override
  void visitIndexExpression(IndexExpression node) {
    super.visitIndexExpression(node);

    if (isListOrSubclass(node.realTarget.staticType)) {
      final index = node.index;

      if (index is IntegerLiteral && index.value == 0) {
        _expressions.add(node);
      }
    }
  }
}
