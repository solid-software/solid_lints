import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:solid_lints/src/lints/avoid_non_null_assertion/avoid_non_null_assertion_rule.dart';

/// visitor for [AvoidNonNullAssertionRule]
class AvoidNonNullAssertionVisitor extends SimpleAstVisitor<void> {
  /// Rule associated with this visitor
  final AvoidNonNullAssertionRule rule;

  /// Creates an instance of [AvoidNonNullAssertionVisitor]
  AvoidNonNullAssertionVisitor(this.rule);

  @override
  void visitPostfixExpression(PostfixExpression node) {
    if (node.operator.type != TokenType.BANG) {
      return;
    }

    final operand = node.operand;

    if (operand is IndexExpression) {
      final type = operand.target?.staticType;

      if (_isMap(type)) {
        return;
      }
    }

    rule.reportAtNode(node);
  }

  bool _isMap(DartType? type) {
    if (type is! InterfaceType) {
      return false;
    }

    return type.isDartCoreMap || type.allSupertypes.any((v) => v.isDartCoreMap);
  }
}
