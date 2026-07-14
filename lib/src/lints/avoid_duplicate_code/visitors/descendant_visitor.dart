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
  void visitBlock(Block node) {
    if (node != root) {
      suppressed.add(node);
    }
    super.visitBlock(node);
  }

  @override
  void visitExpressionFunctionBody(ExpressionFunctionBody node) {
    if (node != root) {
      suppressed.add(node);
    }
    super.visitExpressionFunctionBody(node);
  }
}
