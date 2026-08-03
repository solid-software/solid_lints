import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:solid_lints/src/lints/avoid_returning_widgets/avoid_returning_widgets_rule.dart';
import 'package:solid_lints/src/lints/avoid_returning_widgets/models/avoid_returning_widgets_parameters.dart';
import 'package:solid_lints/src/utils/node_utils.dart';
import 'package:solid_lints/src/utils/types_utils.dart';

/// A visitor that reports on functions that return widgets.
class AvoidReturningWidgetsVisitor extends RecursiveAstVisitor<void> {
  final AvoidReturningWidgetsRule _rule;
  final AvoidReturningWidgetsParameters _parameters;

  /// Creates a new instance of [AvoidReturningWidgetsVisitor]
  AvoidReturningWidgetsVisitor(this._rule, this._parameters);

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    super.visitFunctionDeclaration(node);

    _visitDeclaration(node);
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    super.visitMethodDeclaration(node);

    _visitDeclaration(node);
  }

  @override
  void visitFunctionDeclarationStatement(FunctionDeclarationStatement node) {
    super.visitFunctionDeclarationStatement(node);

    _visitDeclaration(node.functionDeclaration);
  }

  void _visitDeclaration(Declaration node) {
    if (node is! FunctionDeclaration && node is! MethodDeclaration) {
      return;
    }

    if (node is MethodDeclaration &&
        (node.isAbstract ||
            node.body is EmptyFunctionBody ||
            (node.isGetter && _isStateWidgetCastingGetter(node)))) {
      return;
    }

    final returnType = switch (node) {
      MethodDeclaration(:final declaredFragment?) =>
        declaredFragment.element.returnType,
      FunctionDeclaration(:final declaredFragment?) =>
        declaredFragment.element.returnType,
      _ => null,
    };
    if (returnType == null) return;

    final isWidgetReturned = isWidgetType(returnType);
    if (!isWidgetReturned) return;

    final isIgnored = _parameters.exclude.shouldIgnore(node);
    if (isIgnored) return;

    if (_isOverridden(node)) return;

    _rule.reportAtNode(node);
  }

  bool _isStateWidgetCastingGetter(MethodDeclaration node) {
    final enclosingElement = node.declaredFragment?.element.enclosingElement;
    if (enclosingElement is! InterfaceElement ||
        !isWidgetStateOrSubclass(enclosingElement.thisType)) {
      return false;
    }

    final element = node.singleReturnExpression.unwrapTarget?.memberElement;
    final enclosing = element?.enclosingElement;

    return element is PropertyAccessorElement &&
        enclosing is InterfaceElement &&
        isWidgetStateOrSubclass(enclosing.thisType);
  }

  bool _isOverridden(Declaration node) {
    if (node is MethodDeclaration &&
        node.metadata.any((m) => m.name.name == 'override')) {
      return true;
    }

    return switch (node) {
      Declaration(
        declaredFragment: Fragment(
          element: Element(
            name: final String name,
            enclosingElement: final InterfaceElement enclosingElement,
          ),
        ),
      ) =>
        enclosingElement.getInheritedMember(
              Name.forLibrary(enclosingElement.library, name),
            ) !=
            null,
      _ => false,
    };
  }
}
