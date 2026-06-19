import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:solid_lints/src/lints/avoid_unnecessary_type_assertions/avoid_unnecessary_type_assertions_rule.dart';
import 'package:solid_lints/src/utils/typecast_utils.dart';

/// Visitor for [AvoidUnnecessaryTypeAssertionsRule].
/// Reports on unnecessary usage of 'is' operator.
///
/// ### Example:
/// {@template solid_lints.avoid_unnecessary_type_assertions.example_is}
/// #### BAD:
/// ```dart
/// final testList = [1.0, 2.0, 3.0];
/// final result = testList is List<double>; // LINT
/// final negativeResult = testList is! List<double>; // LINT
///
/// final double d = 2.0;
/// final casted = d is double; // LINT
/// ```
///
/// #### GOOD:
/// ```dart
/// final double? nullableD = 2.0;
/// // casting `Type? is Type` is allowed
/// final castedD = nullableD is double;
/// ```
/// {@endtemplate}
class UnnecessaryIsExpressionVisitor extends SimpleAstVisitor<void> {
  final AvoidUnnecessaryTypeAssertionsRule _rule;

  /// Creates a new instance of [UnnecessaryIsExpressionVisitor].
  UnnecessaryIsExpressionVisitor(this._rule);

  @override
  void visitIsExpression(IsExpression node) {
    super.visitIsExpression(node);

    if (!_isUnnecessaryIsExpression(node)) return;

    _rule.reportAtNode(
      node,
      arguments: [
        "'${AvoidUnnecessaryTypeAssertionsRule.operatorIsName}' operator",
      ],
    );
  }

  bool _isUnnecessaryIsExpression(IsExpression node) {
    final objectType = node.expression.staticType;
    final castedType = node.type.type;

    if (objectType == null || castedType == null) {
      return false;
    }

    final typeCast = TypeCast(
      source: objectType,
      target: castedType,
      isReversed: node.notOperator != null,
    );
    return typeCast.isUnnecessaryTypeCheck;
  }
}
