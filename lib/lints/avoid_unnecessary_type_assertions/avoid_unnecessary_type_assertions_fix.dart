part of 'avoid_unnecessary_type_assertions_rule.dart';

/// A Quick fix for `avoid-unnecessary-type-assertions` rule
/// Suggests to remove unnecessary assertions
class _UnnecessaryTypeAssertionsFix extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    context.registry.addIsExpression((node) {
      // checks that the literal declaration is where our warning is located
      if (!analysisError.sourceRange.intersects(node.sourceRange)) return;

      final changeBuilder = reporter.createChangeBuilder(
        message: "Remove unnecessary 'is'",
        priority: 1,
      );

      final isOperatorOffset = node.isOperator.offset;
      changeBuilder.addDartFileEdit((builder) {
        builder.addDeletion(
          SourceRange(
            isOperatorOffset,
            node.length - (isOperatorOffset - node.offset),
          ),
        );
      });
    });

    context.registry.addMethodInvocation((node) {
      // checks that the literal declaration is where our warning is located
      if (!analysisError.sourceRange.intersects(node.sourceRange)) return;

      final changeBuilder = reporter.createChangeBuilder(
        message: "Remove unnecessary 'whereType'",
        priority: 1,
      );

      final operatorOffset = node.operator?.offset ?? node.offset;
      changeBuilder.addDartFileEdit((builder) {
        builder.addDeletion(
          SourceRange(
            operatorOffset,
            node.length - (operatorOffset - node.offset),
          ),
        );
      });
    });
  }
}
