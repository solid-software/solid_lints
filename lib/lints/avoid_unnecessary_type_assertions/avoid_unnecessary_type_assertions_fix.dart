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
      if (analysisError.sourceRange.intersects(node.sourceRange)) {
        _addDeletion(reporter, 'is', node, node.isOperator.offset);
      }
    });

    context.registry.addMethodInvocation((node) {
      if (analysisError.sourceRange.intersects(node.sourceRange)) {
        _addDeletion(
          reporter,
          'whereType',
          node,
          node.operator?.offset ?? node.offset,
        );
      }
    });
  }

  void _addDeletion(
    ChangeReporter reporter,
    String itemToDelete,
    Expression node,
    int operatorOffset,
  ) {
    final targetNameLength = operatorOffset - node.offset;
    final removedPartLength = node.length - targetNameLength;

    final changeBuilder = reporter.createChangeBuilder(
      message: "Remove unnecessary '$itemToDelete'",
      priority: 1,
    );

    changeBuilder.addDartFileEdit((builder) {
      builder.addDeletion(SourceRange(operatorOffset, removedPartLength));
    });
  }
}
