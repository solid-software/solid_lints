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
  VariableDeclaration? get variable => _variable;

  @override
  void visitVariableDeclaration(VariableDeclaration node) {
    final element = node.declaredFragment?.element;
    if (element != null &&
        element.isPrivate &&
        element.isFinal &&
        element.id == _getterId) {
      _variable = node;
    }

    super.visitVariableDeclaration(node);
  }
}

extension on MethodDeclaration {
  int? get getterReferenceId {
    if (body is! ExpressionFunctionBody) return null;

    final expression = (body as ExpressionFunctionBody).expression;
    if (expression is SimpleIdentifier) {
      final element = expression.element;
      if (element is PropertyAccessorElement) {
        return element.variable.id;
      }
    }

    return null;
  }
}
