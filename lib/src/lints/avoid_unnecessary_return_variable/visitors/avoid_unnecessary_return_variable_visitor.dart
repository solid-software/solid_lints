import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:solid_lints/src/common/visitors/select_expression_identifiers_visitor.dart';
import 'package:solid_lints/src/lints/avoid_unnecessary_return_variable/avoid_unnecessary_return_variable_rule.dart';
import 'package:solid_lints/src/lints/avoid_unnecessary_return_variable/visitors/return_variable_usage_visitor.dart';

/// Visitor for [AvoidUnnecessaryReturnVariableRule].
class AvoidUnnecessaryReturnVariableVisitor extends SimpleAstVisitor<void> {
  /// The rule associated with this visitor.
  final AvoidUnnecessaryReturnVariableRule rule;

  /// Creates a new instance of [AvoidUnnecessaryReturnVariableVisitor].
  AvoidUnnecessaryReturnVariableVisitor(this.rule);

  @override
  void visitReturnStatement(ReturnStatement node) {
    final expr = node.expression;
    if (expr is! SimpleIdentifier) {
      return;
    }

    final element = expr.element;
    if (element is! LocalVariableElement) {
      return;
    }

    if (!element.isFinal && !element.isConst) {
      return;
    }

    final block = node.parent;
    if (block == null) return;

    final returnVariableUsageVisitor =
        ReturnVariableUsageVisitor(node, element);

    block.visitChildren(returnVariableUsageVisitor);
    if (!returnVariableUsageVisitor.hasBadStatementCount()) return;

    //it is 100% bad if return statement follows declaration
    if (!returnVariableUsageVisitor.foundTokensBetweenDeclarationAndReturn) {
      rule.reportAtNode(node);
      return;
    }

    final declaration = returnVariableUsageVisitor.variableDeclaration;

    //check if immutable
    final initializer = declaration?.initializer;
    if (initializer == null) return;

    if (!_isExpressionImmutable(initializer)) return;

    rule.reportAtNode(node);
  }

  bool _isExpressionImmutable(Expression expr) {
    final visitor = SelectExpressionIdentifiersVisitor();
    expr.accept(visitor);

    return visitor.identifiers.every(_isSimpleIdentifierImmutable);
  }

  bool _isSimpleIdentifierImmutable(SimpleIdentifier identifier) {
    switch (identifier.element) {
      case final VariableElement variable:
        return variable.isFinal || variable.isConst;

      case ClassElement _:
        return true;

      case GetterElement(:final PropertyInducingElement variable):
        return variable.isFinal || variable.isConst;
    }

    return false;
  }
}
