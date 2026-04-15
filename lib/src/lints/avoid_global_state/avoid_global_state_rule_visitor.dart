import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:solid_lints/src/lints/avoid_global_state/avoid_global_state_rule.dart';

/// Visitor for [AvoidGlobalStateRule].
class AvoidGlobalStateRuleVisitor extends SimpleAstVisitor<void> {
  /// The rule this visitor is associated with.
  final AvoidGlobalStateRule rule;

  /// Creates an instance of [AvoidGlobalStateRuleVisitor].
  AvoidGlobalStateRuleVisitor(this.rule);

  @override
  void visitTopLevelVariableDeclaration(TopLevelVariableDeclaration node) {
    for (final variable in node.variables.variables) {
      if (_isPublicMutable(variable)) {
        rule.reportAtNode(variable);
      }
    }
  }

  @override
  void visitFieldDeclaration(FieldDeclaration node) {
    if (!node.isStatic) return;

    for (final variable in node.fields.variables) {
      if (_isPublicMutable(variable)) {
        rule.reportAtNode(variable);
      }
    }
  }

  /// Returns true if the variable is mutable and not private.
  bool _isPublicMutable(VariableDeclaration variable) {
    return _isMutable(variable) && !_isPrivate(variable);
  }

  /// A variable is mutable if it is not final or const.
  bool _isMutable(VariableDeclaration variable) {
    final parent = variable.parent;
    return parent is VariableDeclarationList &&
        !parent.isFinal &&
        !parent.isConst;
  }

  /// A variable is private if its element is private.
  bool _isPrivate(VariableDeclaration variable) {
    final element = variable.declaredFragment?.element;
    return element?.isPrivate ?? false;
  }
}
