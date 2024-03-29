import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

/// The AST visitor that will collect every If statement
class IfStatementVisitor extends RecursiveAstVisitor<void> {
  final _nodes = <IfStatement>[];

  /// All unnecessary if statements and conditional expressions.
  Iterable<IfStatement> get nodes => _nodes;

  @override
  void visitIfStatement(IfStatement node) {
    super.visitIfStatement(node);
    _nodes.add(node);
  }
}
