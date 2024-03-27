import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

/// The AST visitor that will collect every return statement
class ReturnStatementVisitor extends RecursiveAstVisitor<void> {
  final _nodes = <ReturnStatement>[];

  /// All unnecessary if statements and conditional expressions.
  Iterable<ReturnStatement> get nodes => _nodes;

  @override
  void visitReturnStatement(ReturnStatement node) {
    super.visitReturnStatement(node);
    _nodes.add(node);
  }
}
