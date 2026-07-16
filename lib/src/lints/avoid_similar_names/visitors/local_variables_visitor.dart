import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:solid_lints/src/lints/avoid_similar_names/models/scope_variable.dart';

/// Collects local variable declarations within a function body,
/// stopping at nested function boundaries.
class LocalVariablesVisitor extends RecursiveAstVisitor<void> {
  /// The collected variables.
  final List<ScopeVariable> variables = [];

  @override
  void visitVariableDeclaration(VariableDeclaration node) {
    _collect(node.name, node.declaredFragment?.element.type, node);
    super.visitVariableDeclaration(node);
  }

  @override
  void visitDeclaredIdentifier(DeclaredIdentifier node) {
    _collect(node.name, node.declaredFragment?.element.type, node);
    super.visitDeclaredIdentifier(node);
  }

  @override
  void visitDeclaredVariablePattern(DeclaredVariablePattern node) {
    _collect(node.name, node.declaredFragment?.element.type, node);
    super.visitDeclaredVariablePattern(node);
  }

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    // Stop traversing nested function scopes.
  }

  @override
  void visitFunctionExpression(FunctionExpression node) {
    // Stop traversing nested closures.
  }

  void _collect(Token nameToken, DartType? type, AstNode node) {
    final variable = ScopeVariable.createOrNull(
      nameToken: nameToken,
      type: type,
      node: node,
    );
    if (variable != null) {
      variables.add(variable);
    }
  }
}
