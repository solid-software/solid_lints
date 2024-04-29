import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// A Quick fix for `prefer_first` rule
/// Suggests to replace iterable access expressions
class PreferFirstFix extends DartFix {
  static const _replaceComment = "Replace with 'first'.";

  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    context.registry.addMethodInvocation((node) {
      if (analysisError.sourceRange.intersects(node.sourceRange)) {
        final correction = _createCorrection(node);

        _addReplacement(reporter, node, correction);
      }
    });

    context.registry.addIndexExpression((node) {
      if (analysisError.sourceRange.intersects(node.sourceRange)) {
        final correction = _createCorrection(node);

        _addReplacement(reporter, node, correction);
      }
    });
  }

  String _createCorrection(Expression expression) {
    if (expression is MethodInvocation) {
      return expression.isCascaded
          ? '..first'
          : '${expression.target ?? ''}.first';
    } else if (expression is IndexExpression) {
      return expression.isCascaded
          ? '..first'
          : '${expression.target ?? ''}.first';
    } else {
      return '.first';
    }
  }

  void _addReplacement(
    ChangeReporter reporter,
    Expression node,
    String correction,
  ) {
    final changeBuilder = reporter.createChangeBuilder(
      message: _replaceComment,
      priority: 1,
    );

    changeBuilder.addDartFileEdit((builder) {
      builder.addSimpleReplacement(
        SourceRange(node.offset, node.length),
        correction,
      );
    });
  }
}
