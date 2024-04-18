import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:solid_lints/src/lints/avoid_final_with_getter/visitors/variable_getter_visitor.dart';

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

    final visitor = VariableGetterVisitor(node);
    node.parent?.parent?.parent?.accept(visitor);

    if (visitor.getter != null) {
      _variables.add(node);
    }
    super.visitVariableDeclaration(node);
  }
}
