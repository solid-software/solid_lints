import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:solid_lints/src/lints/avoid_final_with_getter/visitors/getter_variable_visitor.dart';

/// A visitor that checks for final private fields with getters.
/// If a final private field has a getter, it is considered as a public field.
class AvoidFinalWithGetterVisitor extends RecursiveAstVisitor<void> {
  final _getters = <MethodDeclaration>[];

  /// List of getters
  Iterable<MethodDeclaration> get getters => _getters;

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    if (node
        case MethodDeclaration(
          isGetter: true,
          declaredElement: ExecutableElement(
            isAbstract: false,
            isStatic: false,
            isPublic: true,
          )
        )) {
      final visitor = GetterVariableVisitor(node);
      node.parent?.accept(visitor);

      if (visitor.hasVariable) {
        _getters.add(node);
      }
    }
    super.visitMethodDeclaration(node);
  }
}
