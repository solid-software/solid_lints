import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';

/// A visitor that checks the association of the getter with
/// the final private variable
class GetterVariableVisitor extends RecursiveAstVisitor<void> {
  final int? _getterId;
  VariableDeclaration? _variable;

  /// Creates a new instance of [GetterVariableVisitor]
  GetterVariableVisitor(MethodDeclaration getter)
      : _getterId = getter.getterReferenceId;

  /// Is there a variable associated with the getter
  bool get hasVariable => _variable != null;

  @override
  void visitVariableDeclaration(VariableDeclaration node) {
    if (node
        case VariableDeclaration(
          isFinal: true,
          declaredElement: VariableElement(id: final id, isPrivate: true)
        ) when id == _getterId) {
      _variable = node;
    }

    super.visitVariableDeclaration(node);
  }
}

extension on MethodDeclaration {
  int? get getterReferenceId => switch (body) {
        ExpressionFunctionBody(
          expression: SimpleIdentifier(
            staticElement: Element(
              declaration: PropertyAccessorElement(
                variable: PropertyInducingElement(:final id)
              )
            )
          )
        ) =>
          id,
        _ => null,
      };
}
