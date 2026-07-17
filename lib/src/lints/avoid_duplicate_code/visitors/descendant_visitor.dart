import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

/// A visitor that collects descendant candidate blocks to suppress them.
class DescendantVisitor extends RecursiveAstVisitor<void> {
  /// The set of suppressed nodes.
  final Set<AstNode> suppressed;

  /// The root node from which to start the descent.
  final AstNode root;

  /// Creates a new instance of [DescendantVisitor].
  DescendantVisitor(this.suppressed, this.root);

  @override
  void visitBlock(Block node) => _visit(node, super.visitBlock);

  @override
  void visitExpressionFunctionBody(ExpressionFunctionBody node) =>
      _visit(node, super.visitExpressionFunctionBody);

  void _visit<T extends AstNode>(T node, void Function(T) visitSuper) {
    if (node != root) suppressed.add(node);
    visitSuper(node);
  }
}
