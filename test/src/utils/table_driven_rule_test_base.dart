import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:test/test.dart' hide setUp;

import '../../lints/auto_test_lint_offsets.dart';

/// Result expected from a table-driven test case.
enum ExpectedResult {
  /// The test case should pass without diagnostics.
  pass,

  /// The test case should fail with a lint diagnostic.
  fail,
}

/// Base class for table-driven lint rule tests.
abstract class TableDrivenRuleTest<T> extends AnalysisRuleTest
    with AutoTestLintOffsets {
  /// Disposes and recreates the analysis context.
  Future<void> resetAnalyzerContext() async {
    // ignore: invalid_use_of_visible_for_testing_member
    await super.tearDown();
    setUp();
  }

  /// Generates the test source code for a given [testCase] based on [expected].
  String generateCode(T testCase, ExpectedResult expected);

  /// Executes all test cases defined in the [testTable] map.
  Future<void> runTableTests(Map<T, ExpectedResult> testTable) async {
    for (final MapEntry(key: testCase, value: expected) in testTable.entries) {
      final source = generateCode(testCase, expected);

      try {
        switch (expected) {
          case ExpectedResult.pass:
            await assertNoDiagnostics(source);
          case ExpectedResult.fail:
            await assertAutoDiagnostics(source);
        }
      } on TestFailure catch (e) {
        fail('Case $testCase: $e');
      }

      // Reset the analysis context between test cases to bypass the analyzer's
      // internal caching and ensure the newly generated code is re-analyzed.
      await resetAnalyzerContext();
    }
  }
}
