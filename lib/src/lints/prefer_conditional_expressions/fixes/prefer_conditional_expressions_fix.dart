import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:solid_lints/src/lints/prefer_conditional_expressions/prefer_conditional_expressions_rule.dart';
import 'package:solid_lints/src/lints/prefer_conditional_expressions/visitors/prefer_conditional_expressions_visitor.dart';

/// A Quick fix for `prefer_conditional_expressions` rule
/// Suggests to convert simple if statements to conditional expressions
class PreferConditionalExpressionsFix extends ResolvedCorrectionProducer {
  static const _fixComment = "Convert to conditional expression.";

  /// Creates a new instance of [PreferConditionalExpressionsFix]
  PreferConditionalExpressionsFix({required super.context});

  @override
  FixKind get fixKind => const FixKind(
    'solid_lints.fix.${PreferConditionalExpressionsRule.lintName}',
    DartFixKindPriority.standard,
    _fixComment,
  );

  @override
  FixKind get multiFixKind => const FixKind(
    'solid_lints.fix.multi.${PreferConditionalExpressionsRule.lintName}',
    DartFixKindPriority.standard,
    '$_fixComment across files',
  );

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.automatically;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final statement = node.thisOrAncestorOfType<IfStatement>();
    if (statement == null) return;

    final statementInfo = StatementInfo.fromIfStatement(statement);
    if (statementInfo == null) return;

    final correction = _createCorrection(statementInfo);
    if (correction == null) return;

    await builder.addDartFileEdit(
      file,
      (builder) => builder.addSimpleReplacement(
        statement.sourceRange,
        correction,
      ),
    );
  }

  String? _createCorrection(StatementInfo info) {
    final thenStatement = info.unwrappedThenStatement;
    final elseStatement = info.unwrappedElseStatement;

    final condition = info.statement.expression;

    if (thenStatement is AssignmentExpression &&
        elseStatement is AssignmentExpression) {
      final target = thenStatement.leftHandSide;
      final firstExpression = thenStatement.rightHandSide;
      final secondExpression = elseStatement.rightHandSide;
      final op = thenStatement.operator.lexeme;

      final correctionForLiterals = _createCorrectionForLiterals(
        condition,
        firstExpression,
        secondExpression,
      );

      return '$target $op $correctionForLiterals';
    }

    if (thenStatement is ReturnStatement && elseStatement is ReturnStatement) {
      final firstExpression = thenStatement.expression;
      final secondExpression = elseStatement.expression;
      final correction = _createCorrectionForLiterals(
        condition,
        firstExpression,
        secondExpression,
      );

      return 'return $correction';
    }

    return null;
  }

  String _createCorrectionForLiterals(
    Expression condition,
    Expression? firstExpression,
    Expression? secondExpression,
  ) {
    if (firstExpression is BooleanLiteral &&
        secondExpression is BooleanLiteral) {
      if (firstExpression.value == secondExpression.value) {
        return '${firstExpression.value};';
      }
      final isInverted = !firstExpression.value && secondExpression.value;

      return '${isInverted ? "!" : ""}$condition;';
    }

    return '$condition ? $firstExpression : $secondExpression;';
  }
}
