import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:solid_lints/src/lints/reverse_if_to_avoid_nesting/visitors/return_statement_visitor.dart';

/// The AST visitor that will collect all unnecessary if statements and
/// conditional expressions.
class ReverseIfToAvoidNestingVisitor extends RecursiveAstVisitor<void> {
  final _nodes = <IfStatement>[];

  /// All unnecessary if statements and conditional expressions.
  Iterable<IfStatement> get nodes => _nodes;

  @override
  void visitIfStatement(IfStatement node) {
    super.visitIfStatement(node);

    if (_hasElseStatement(node)) return;
    if (_isElseifStatement(node)) return;
    if (_containsReturn(node)) return;

    _nodes.add(node);
  }
}

bool _hasElseStatement(IfStatement node) {
  return node.elseStatement != null;
}

bool _isElseifStatement(IfStatement node) {
  return node.ifKeyword.previous?.keyword == Keyword.ELSE;
}

bool _containsReturn(IfStatement node) {
  final visitor = ReturnStatementVisitor();
  node.thenStatement.accept(visitor);
  return visitor.nodes.isNotEmpty;
}
