import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

/// The AST visitor that will collect every Return statement
class ThrowExpressionVisitor extends RecursiveAstVisitor<void> {
  final _nodes = <ThrowExpression>[];

  /// All unnecessary return statements
  Iterable<ThrowExpression> get nodes => _nodes;

  @override
  void visitThrowExpression(ThrowExpression node) {
    super.visitThrowExpression(node);
    _nodes.add(node);
  }
}
