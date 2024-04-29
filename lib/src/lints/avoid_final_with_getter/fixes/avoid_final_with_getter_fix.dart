part of '../avoid_final_with_getter_rule.dart';

class _FinalWithGetterFix extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    context.registry.addMethodDeclaration((node) {
      if (analysisError.sourceRange.intersects(node.sourceRange)) {
        final info = analysisError.data as FinalWithGetterInfo?;
        if (info == null) return;

        _addReplacement(reporter, info);
      }
    });
  }

  void _addReplacement(
    ChangeReporter reporter,
    FinalWithGetterInfo info,
  ) {
    final changeBuilder = reporter.createChangeBuilder(
      message: "Remove getter and make variable public.",
      priority: 1,
    );

    changeBuilder.addDartFileEdit((builder) {
      builder.addDeletion(info.getter.sourceRange);
      builder.addDeletion(SourceRange(info.variable.name.offset, 1));
    });
  }
}
