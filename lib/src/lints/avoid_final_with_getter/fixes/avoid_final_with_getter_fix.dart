part of '../avoid_final_with_getter_rule.dart';

class _FinalWithGetterFix extends DartFix {
  final Expando<FinalWithGetterInfo> _diagnosticsInfoExpando;

  _FinalWithGetterFix(this._diagnosticsInfoExpando);

  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    Diagnostic diagnostic,
    List<Diagnostic> others,
  ) {
    context.registry.addMethodDeclaration((node) {
      if (!diagnostic.sourceRange.intersects(node.sourceRange)) return;

      final info = _diagnosticsInfoExpando[diagnostic];
      if (info == null) return;

      _addReplacement(reporter, info);
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
