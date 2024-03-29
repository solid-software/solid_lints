import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:solid_lints/src/lints/feature_envy/visitors/field_access_visitor.dart';

/// The AST visitor that will collect and return every case of feature envy
class FeatureEnvyVisitor extends RecursiveAstVisitor<void> {
  final _nodes = <AstNode>[];

  /// All unnecessary if statements and conditional expressions.
  Iterable<AstNode> get nodes => _nodes;

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    super.visitClassDeclaration(node);
    final visitor = FieldAccessVisitor(parentClass: node);
    node.accept(visitor);

    if (visitor.isFeatureEnvy) {
      _nodes.addAll(visitor.externalClassAccessList);
    }
  }
}
