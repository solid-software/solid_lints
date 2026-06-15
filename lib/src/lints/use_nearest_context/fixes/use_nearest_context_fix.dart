part of '../use_nearest_context_rule.dart';

/// A Quick fix for `use_nearest_context` rule
/// Suggests to renaming the nearest BuildContext variable
/// to the one that is being used
class _UseNearestContextFix extends DartFix {
  static const _replaceComment = "Rename nearest BuildContext parameter";

  final Expando<StatementInfo> _diagnosticsInfoExpando;

  _UseNearestContextFix(this._diagnosticsInfoExpando);

  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    Diagnostic diagnostic,
    List<Diagnostic> others,
  ) {
    final statementInfo = _diagnosticsInfoExpando[diagnostic];
    if (statementInfo == null) return;
    final parameterName = statementInfo.parameter.name;
    if (parameterName == null) return;

    _addReplacement(reporter, parameterName, statementInfo.name);
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

/// Data class that holds info required for the [_UseNearestContextFix].
class StatementInfo {
  /// Creates instance of a [StatementInfo].
  const StatementInfo({
    required this.name,
    required this.parameter,
  });

  /// The name of the outer BuildContext variable that was used
  /// instead of the nearest one.
  final String name;

  /// The nearest [SimpleFormalParameter] of type BuildContext
  /// that should have been used instead.
  final SimpleFormalParameter parameter;
}
