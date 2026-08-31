import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:solid_lints/src/lints/avoid_non_null_assertion/avoid_non_null_assertion_rule.dart';
import 'package:solid_lints/src/lints/avoid_non_null_assertion/models/avoid_non_null_assertion_parameters.dart';

/// visitor for [AvoidNonNullAssertionRule]
class AvoidNonNullAssertionVisitor extends SimpleAstVisitor<void> {
  /// Rule associated with this visitor
  final AvoidNonNullAssertionRule rule;

  final AvoidNonNullAssertionParameters _parameters;

  /// Creates an instance of [AvoidNonNullAssertionVisitor]
  AvoidNonNullAssertionVisitor(this.rule, this._parameters);

  @override
  void visitPostfixExpression(PostfixExpression node) {
    if (node.operator.type != TokenType.BANG) {
      return;
    }

    final operand = node.operand.unParenthesized;

    if (operand is IndexExpression) {
      final type = operand.target?.staticType;

      if (_parameters.ignoredTypes.shouldIgnore(type)) {
        return;
      }
    }

    rule.reportAtNode(node);
  }
}
