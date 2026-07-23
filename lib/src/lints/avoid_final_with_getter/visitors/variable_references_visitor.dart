import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/syntactic_entity.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';

/// Finds all references to a variable declaration.
class VariableReferencesVisitor extends RecursiveAstVisitor<void> {
  final VariableDeclaration _variableDeclaration;
  final List<SyntacticEntity> _references = [];

  /// List of found references to the variable declaration.
  List<SyntacticEntity> get references => _references;

  /// Creates a new instance of [VariableReferencesVisitor]
  VariableReferencesVisitor(this._variableDeclaration);

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    super.visitSimpleIdentifier(node);

    final variableId = _variableDeclaration.declaredFragment?.element.id;
    final referencedVariableId = switch (node.element) {
      PropertyAccessorElement(:final variable) => variable.id,
      final element? => element.id,
      _ => null,
    };

    if (referencedVariableId == variableId) {
      _references.add(node);
    }
  }
}
