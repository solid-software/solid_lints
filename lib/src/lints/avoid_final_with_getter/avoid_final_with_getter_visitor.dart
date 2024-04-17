import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';

/// A visitor that checks for final private fields with getters.
/// If a final private field has a getter, it is considered as a public field.
class AvoidFinalWithGetterVisitor extends RecursiveAstVisitor<void> {
  final _variables = <VariableDeclaration>[];

  /// List of final private fields with getters
  Iterable<VariableDeclaration> get variables => _variables;

  @override
  void visitVariableDeclaration(VariableDeclaration node) {
    final isPrivate = node.declaredElement?.isPrivate ?? false;
    final isFinalPrivate = node.isFinal && isPrivate;

    if (!isFinalPrivate) return;

    final visitor = _GettersVisitor(node);
    node.parent?.parent?.parent?.accept(visitor);

    if (visitor.getter != null) {
      _variables.add(node);
    }
    super.visitVariableDeclaration(node);
  }
}

class _GettersVisitor extends RecursiveAstVisitor<void> {
  final VariableDeclaration variable;
  final String fieldName;

  MethodDeclaration? getter;

  _GettersVisitor(this.variable)
      : fieldName = variable.name.toString().replaceFirst('_', '');

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    final name = node.name.toString();

    if (name == fieldName && node.isGetter) {
      final nodeId = node.getterReferenceId;

      final variableId = variable.variableId;

      if (nodeId == variableId) {
        getter = node;
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
