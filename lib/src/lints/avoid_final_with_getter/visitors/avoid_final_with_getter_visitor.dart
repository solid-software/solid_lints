import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element2.dart';
import 'package:solid_lints/src/lints/avoid_final_with_getter/visitors/getter_variable_visitor.dart';

/// A visitor that checks for final private fields with getters.
/// If a final private field has a getter, it is considered as a public field.
class AvoidFinalWithGetterVisitor extends RecursiveAstVisitor<void> {
  final _getters = <FinalWithGetterInfo>{};

  /// List of getters
  Set<FinalWithGetterInfo> get getters => _getters;

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    if (node
        case MethodDeclaration(
          isGetter: true,
          declaredFragment: ExecutableFragment(
            element: ExecutableElement2(
              isAbstract: false,
              isPublic: true,
            )
          )
        )) {
      final visitor = GetterVariableVisitor(node);
      node.parent?.accept(visitor);

      final variable = visitor.variable;

      if (variable != null) {
        _getters.add(FinalWithGetterInfo(node, variable));
      }
    }
    super.visitMethodDeclaration(node);
  }
}

/// Information about the final private field with a getter.
class FinalWithGetterInfo {
  /// The getter method declaration.
  final MethodDeclaration getter;

  /// The variable declaration.
  final VariableDeclaration variable;

  /// Creates a new instance of [FinalWithGetterInfo]
  const FinalWithGetterInfo(this.getter, this.variable);
}
