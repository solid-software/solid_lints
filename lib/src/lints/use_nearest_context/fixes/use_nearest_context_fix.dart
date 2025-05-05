part of '../use_nearest_context_rule.dart';

/// A Quick fix for `use_nearest_context` rule
/// Suggests to renaming the nearest BuildContext variable
/// to the one that is being used
class _UseNearestContextFix extends DartFix {
  static const _replaceComment = "Rename the BuildContext variable";

  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    context.registry.addFunctionDeclaration((node) {
      final statementInfo = analysisError.data as StatementInfo?;
      if (statementInfo == null) return;
      final parameterName = statementInfo.parameter.name;
      if (parameterName == null) return;
      if (node.sourceRange.intersects(parameterName.sourceRange)) {
        _addReplacement(
          reporter,
          parameterName,
          statementInfo.name,
        );
      }
    });
  }

  void _addReplacement(
    ChangeReporter reporter,
    Token? token,
    String correction,
  ) {
    if (token == null) return;
    final changeBuilder = reporter.createChangeBuilder(
      message: _replaceComment,
      priority: 1,
    );

    changeBuilder.addDartFileEdit((builder) {
      builder.addSimpleReplacement(
        token.sourceRange,
        correction,
      );
    });
  }
}

/// Data class contains info required for fix
class StatementInfo {
  /// Creates instance of an [StatementInfo]
  const StatementInfo({
    required this.name,
    required this.parameter,
  });

  /// Variable name
  final String name;

  /// BuildContext parament
  final SimpleFormalParameter parameter;
}
