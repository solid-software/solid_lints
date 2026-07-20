import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:solid_lints/src/lints/avoid_final_with_getter/utils/getter_reference_id.dart';

/// A visitor that gets the final private variable associated with the getter.
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
    if (node case VariableDeclaration(
      declaredFragment: VariableFragment(
        element: VariableElement(
          isPrivate: true,
          isFinal: true,
          :final id,
        ),
      ),
    ) when id == _getterId) {
      _variable = node;
    }

    super.visitVariableDeclaration(node);
  }
}
