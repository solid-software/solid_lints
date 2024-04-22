import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

/// The AST visitor that will collect every Return statement
class ReturnStatementVisitor extends RecursiveAstVisitor<void> {
  final _nodes = <ReturnStatement>[];

  /// All unnecessary return statements
  Iterable<ReturnStatement> get nodes => _nodes;

  @override
  void visitReturnStatement(ReturnStatement node) {
    super.visitReturnStatement(node);
    _nodes.add(node);
  }
}
