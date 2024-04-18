import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';

/// A visitor that checks for final private fields with getters.
class VariableGetterVisitor extends RecursiveAstVisitor<void> {
  final VariableDeclaration _variable;
  final String _fieldName;
  MethodDeclaration? _getter;

  /// Creates a new instance of [VariableGetterVisitor]
  VariableGetterVisitor(this._variable)
      : _fieldName = _variable.name.toString().replaceFirst('_', '');

  /// The getter of the variable
  MethodDeclaration? get getter => _getter;

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    final name = node.name.toString();

    if (name == _fieldName && node.isGetter) {
      final nodeId = node.getterReferenceId;

      final variableId = _variable.variableId;

      if (nodeId == variableId) {
        _getter = node;
      }
    }
    super.visitMethodDeclaration(node);
  }
}

extension on MethodDeclaration {
  int? get getterReferenceId => switch (body) {
        ExpressionFunctionBody(
          expression: SimpleIdentifier(
            staticElement: Element(
              declaration: PropertyAccessorElement(
                variable: PropertyInducingElement(id: final int id)
              )
            )
          )
        ) =>
          id,
        _ => null,
      };
}

extension on VariableDeclaration {
  int? get variableId => switch (declaredElement) {
        VariableElement(id: final int id) => id,
        _ => null,
      };
}
