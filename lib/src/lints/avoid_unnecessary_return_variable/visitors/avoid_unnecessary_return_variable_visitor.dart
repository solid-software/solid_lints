import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:solid_lints/src/common/visitors/select_expression_identifiers_visitor.dart';
import 'package:solid_lints/src/lints/avoid_unnecessary_return_variable/avoid_unnecessary_return_variable_rule.dart';
import 'package:solid_lints/src/lints/avoid_unnecessary_return_variable/visitors/return_variable_usage_visitor.dart';

/// Visitor for [AvoidUnnecessaryReturnVariableRule].
class AvoidUnnecessaryReturnVariableVisitor extends SimpleAstVisitor<void> {
  /// The rule associated with this visitor.
  final AvoidUnnecessaryReturnVariableRule _rule;

  /// Creates a new instance of [AvoidUnnecessaryReturnVariableVisitor].
  AvoidUnnecessaryReturnVariableVisitor(this._rule);

  @override
  void visitReturnStatement(ReturnStatement node) {
    final expr = node.expression?.unParenthesized;
    if (expr is! SimpleIdentifier) return;

    final element = expr.element;
    if (element is! LocalVariableElement) return;

    if (!element.isFinal && !element.isConst) return;

    //get enclosing block function body
    final functionBody = node.thisOrAncestorOfType<BlockFunctionBody>();
    if (functionBody == null) return;
    final block = functionBody.block;

    final returnVariableUsageVisitor = ReturnVariableUsageVisitor(
      node,
      element,
    );

    block.visitChildren(returnVariableUsageVisitor);
    if (!returnVariableUsageVisitor.hasBadStatementCount) return;

    //check if declaration statement is found
    final declaration = returnVariableUsageVisitor.variableDeclaration;
    if (declaration == null) return;

    //it is 100% bad if return statement follows declaration
    if (!returnVariableUsageVisitor.foundTokensBetweenDeclarationAndReturn) {
      _rule.reportAtNode(node);
      return;
    }

    //check if immutable
    final initializer = declaration.initializer;
    if (initializer == null) return;

    if (!_isExpressionImmutable(initializer)) return;

    _rule.reportAtNode(node);
  }

  bool _isExpressionImmutable(Expression expr) {
    final visitor = SelectExpressionIdentifiersVisitor();
    expr.accept(visitor);

    return visitor.identifiers.every(_isSimpleIdentifierImmutable);
  }

  bool _isSimpleIdentifierImmutable(SimpleIdentifier identifier) {
    return switch (identifier.element) {
      ClassElement _ => true,
      final VariableElement variable => variable.isFinal || variable.isConst,
      GetterElement(:final PropertyInducingElement variable) =>
        variable.isFinal || variable.isConst,
      _ => false,
    };
  }
}
