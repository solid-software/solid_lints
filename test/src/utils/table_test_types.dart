import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';

/// Result expected from a table-driven test case.
enum ExpectedResult {
  /// The test case should pass without diagnostics.
  pass,

  /// The test case should fail with a lint diagnostic.
  fail,
}

/// Mixin to allow manual analyzer context resets in table-driven tests.
mixin AnalyzerContextResetMixin on AnalysisRuleTest {
  /// Disposes and recreates the analysis context.
  Future<void> resetAnalyzerContext() async {
    // ignore: invalid_use_of_visible_for_testing_member
    await super.tearDown();
    setUp();
  }
}
