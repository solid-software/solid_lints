import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:solid_lints/lints/prefer_conditional_expressions/prefer_conditional_expressions_visitor.dart';

/// A Quick fix for `prefer_conditional_expressions` rule
/// Suggests to remove unnecessary assertions
class PreferConditionalExpressionsFix extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    context.registry.addIfStatement((node) {
      if (analysisError.sourceRange.intersects(node.sourceRange)) {
        final statementInfo = analysisError.data as StatementInfo?;
        if (statementInfo == null) return;

        final correction = _createCorrection(statementInfo);
        if (correction == null) return;

        _addReplacement(reporter, statementInfo.statement, correction);
      }
    });
  }

  void _addReplacement(
    ChangeReporter reporter,
    IfStatement node,
    String correction,
  ) {
    final changeBuilder = reporter.createChangeBuilder(
      message: "Convert to conditional expression.",
      priority: 1,
    );

    changeBuilder.addDartFileEdit((builder) {
      builder.addSimpleReplacement(
        SourceRange(node.offset, node.length),
        correction,
      );
    });
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

      final thenStatementOperator = thenStatement.operator.type;
      final elseStatementOperator = elseStatement.operator.type;

      if (_isAssignmentOperatorNotEq(thenStatementOperator) &&
          _isAssignmentOperatorNotEq(elseStatementOperator)) {
        final prefix = thenStatement.leftHandSide;
        final thenPart =
            '$prefix ${thenStatementOperator.stringValue} $firstExpression';
        final elsePart =
            '$prefix ${elseStatementOperator.stringValue} $secondExpression;';

        return '$condition ? $thenPart : $elsePart';
      }

      final correctionForLiterals = _createCorrectionForLiterals(
        condition,
        firstExpression,
        secondExpression,
      );

      return '$target = $correctionForLiterals';
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
      final isInverted = !firstExpression.value && secondExpression.value;

      return '${isInverted ? "!" : ""}$condition;';
    }

    return '$condition ? $firstExpression : $secondExpression;';
  }

  bool _isAssignmentOperatorNotEq(TokenType token) =>
      token.isAssignmentOperator && token != TokenType.EQ;
}
