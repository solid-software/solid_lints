import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:solid_lints/src/lints/feature_envy/visitors/field_access_different_class_visitor.dart';

/// The AST visitor that will collect and return every case of feature envy
class FeatureEnvyVisitor extends RecursiveAstVisitor<void> {
  final _nodes = <AstNode>[];

  /// All unnecessary if statements and conditional expressions.
  Iterable<AstNode> get nodes => _nodes;

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    super.visitMethodDeclaration(node);
    final parent = node.parent;
    if (parent is! ClassDeclaration) return;
    final visitor = FieldAccessDifferentClassVisitor(
      parentClassName: parent.name.toString(),
    );
    node.accept(visitor);

    for (final el in visitor.nodes) {
      _nodes.add(el);
    }
  }
}
