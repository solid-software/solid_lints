import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:solid_lints/src/lints/prefer_guard_clause/visitors/return_statement_visitor.dart';

/// The AST visitor that will collect all unnecessary if statements and
/// conditional expressions.
class PreferGuardClauseVisitor extends RecursiveAstVisitor<void> {
  final _nodes = <AstNode>[];

  /// All unnecessary if statements and conditional expressions.
  Iterable<AstNode> get nodes => _nodes;

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    super.visitFunctionDeclaration(node);
    _handleFunctionBody(node.functionExpression.body);
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    super.visitMethodDeclaration(node);
    _handleFunctionBody(node.body);
  }

  void _handleFunctionBody(FunctionBody body) {
    if (body is! BlockFunctionBody) return;
    if (body.block.statements.isEmpty) return;

    final first = body.block.statements.first;
    var last = body.block.statements.last;

    switch (body.block.statements.length) {
      case 1:
        if (first is IfStatement) _handleIfStatement(first);
        return;
      case 2:
        break;
      case _:
        if (last is ReturnStatement) {
          last = body.block.statements[body.block.statements.length - 2];
        }
    }

    if (first is IfStatement) _handleIfStatement(first);
    if (last is IfStatement) _handleIfStatement(last);
  }

  void _handleIfStatement(IfStatement node) {
    if (_isElseIfStatement(node)) return;

    if (_hasElseStatement(node)) {
      //if both statements don't contain return statements -> ignore
      //if at least one statement contains return statemnt -> highlight
      if (!_containsReturnStatement(node)) return;
    } else {
      return;
    }

    _nodes.add(node);
  }
}

bool _hasElseStatement(IfStatement node) {
  return node.elseStatement != null;
}

bool _isElseIfStatement(IfStatement node) {
  return node.elseStatement != null && node.elseStatement is IfStatement;
}

bool _containsReturnStatement(Statement node) {
  final visitor = ReturnStatementVisitor();
  node.accept(visitor);
  return visitor.nodes.isNotEmpty;
}
