import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:solid_lints/src/lints/prefer_first/prefer_first_rule.dart';
import 'package:solid_lints/src/utils/types_utils.dart';

/// The AST visitor that will collect all Iterable access expressions
/// which can be replaced with .first
class PreferFirstVisitor extends RecursiveAstVisitor<void> {
  final PreferFirstRule _rule;

  /// Creates a new instance of [PreferFirstVisitor]
  PreferFirstVisitor(this._rule);

  @override
  void visitMethodInvocation(MethodInvocation node) {
    super.visitMethodInvocation(node);
    final isIterable = isIterableOrSubclass(node.realTarget?.staticType);
    final isElementAt = node.methodName.name == 'elementAt';

    if (!isIterable || !isElementAt) return;

    final arg = node.argumentList.arguments.first;

    if (arg case IntegerLiteral(value: 0)) {
      _rule.reportAtNode(node);
    }
  }

  @override
  void visitIndexExpression(IndexExpression node) {
    super.visitIndexExpression(node);

    if (!isListOrSubclass(node.realTarget.staticType)) return;

    final index = node.index;

    if (index case IntegerLiteral(value: 0)) {
      _rule.reportAtNode(node);
    }
  }
}
