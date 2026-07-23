import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:solid_lints/src/lints/avoid_final_with_getter/avoid_final_with_getter_rule.dart';
import 'package:solid_lints/src/lints/avoid_final_with_getter/utils/getter_reference_id.dart';

/// A visitor that checks for final private fields with getters.
/// If a final private field has a getter, it is considered as a public field.
class AvoidFinalWithGetterVisitor extends RecursiveAstVisitor<void> {
  final AvoidFinalWithGetterRule _rule;

  final _gettersPairLookup = <int, MethodDeclaration>{};
  final _fieldsPairLookup = <int, VariableDeclaration>{};

  /// Creates a new instance of [AvoidFinalWithGetterVisitor]
  AvoidFinalWithGetterVisitor(this._rule);

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    super.visitMethodDeclaration(node);

    if (node case MethodDeclaration(
      isGetter: true,
      declaredFragment: ExecutableFragment(
        element: ExecutableElement(
          isAbstract: false,
          isPublic: true,
        ),
      ),
      getterReferenceId: final getterId?,
    )) {
      _gettersPairLookup[getterId] = node;

      if (_fieldsPairLookup.containsKey(getterId)) {
        _rule.reportAtNode(node);
      }
    }
  }

  @override
  void visitVariableDeclaration(VariableDeclaration node) {
    super.visitVariableDeclaration(node);

    if (node case VariableDeclaration(
      declaredFragment: VariableFragment(
        element: VariableElement(
          isPrivate: true,
          isFinal: true,
          id: final variableId,
        ),
      ),
    )) {
      _fieldsPairLookup[variableId] = node;

      if (_gettersPairLookup[variableId] case final getter?) {
        _rule.reportAtNode(getter);
      }
    }
  }
}
