part of 'avoid_unnecessary_type_casts_rule.dart';

/// A Quick fix for `avoid-unnecessary-type-assertions` rule
/// Suggests to remove unnecessary assertions
class _UnnecessaryTypeCastsFix extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    context.registry.addAsExpression((node) {
      if (analysisError.sourceRange.intersects(node.sourceRange)) {
        _addDeletion(reporter, 'as', node, node.asOperator.offset);
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
