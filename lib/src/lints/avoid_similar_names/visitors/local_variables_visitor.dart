import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:solid_lints/src/lints/avoid_similar_names/models/scope_variable.dart';

/// Collects local variable declarations within a function body,
/// stopping at nested function boundaries.
class LocalVariablesVisitor extends RecursiveAstVisitor<void> {
  /// The collected variables.
  final List<ScopeVariable> variables = [];

  @override
  void visitVariableDeclaration(VariableDeclaration node) {
    if (ScopeVariable.createOrNull(
          nameToken: node.name,
          type: node.declaredFragment?.element.type,
          node: node,
        )
        case final variable?) {
      variables.add(variable);
    }
    super.visitVariableDeclaration(node);
  }

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    // Stop traversing nested function scopes.
  }

  @override
  void visitFunctionExpression(FunctionExpression node) {
    // Stop traversing nested closures.
  }
}
