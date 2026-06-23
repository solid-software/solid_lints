import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:analyzer_testing/utilities/utilities.dart';
import 'package:solid_lints/src/common/parameter_parser/analysis_options_loader.dart';
import 'package:solid_lints/src/lints/function_lines_of_code/function_lines_of_code_rule.dart';
import 'package:solid_lints/src/lints/function_lines_of_code/models/function_lines_of_code_parameters.dart';
import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../../../lints/auto_test_lint_offsets.dart';
import '../../utils/code_generators.dart';
import '../../utils/table_test_types.dart';
import 'models/test_case.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(FunctionLinesOfCodeRuleTest);
  });
}

@reflectiveTest
class FunctionLinesOfCodeRuleTest extends AnalysisRuleTest
    with AutoTestLintOffsets, AnalyzerContextResetMixin {
  static const _excludedClassName = 'ExcludedClass';
  static const _nonExcludedClassName = 'NonExcludedClass';
  static const _excludedMethodName = 'excludedMethod';
  static const _excludedMethodByDeclaration = 'excludedMethodByDeclaration';
  static const _excludedFunctionName = 'excludedFunction';
  static const _excludedFunctionByDeclaration = 'excludedFunctionByDeclaration';
  static const _excludedByString = 'excludedByString';

  static const _mockAnalysisOptionsContent =
      '''
plugins:
  solid_lints:
    diagnostics:
      function_lines_of_code:
        max_lines: 4
        exclude:
          - class_name: $_excludedClassName
            method_name: $_excludedMethodName
          - method_name: $_excludedMethodByDeclaration
          - method_name: $_excludedFunctionName
          - method_name: $_excludedFunctionByDeclaration
          - $_excludedByString
  ''';

  /// All test cases for the function_lines_of_code rule.
  static const testTable = <TestCase, ExpectedResult>{
    // --- Threshold: fail when code lines > max (4) ---
    TestCase(codeLines: 5): ExpectedResult.fail,
    TestCase(codeLines: 5, comments: true): ExpectedResult.fail,

    // --- Threshold: pass when code lines ≤ max (4) ---
    TestCase(codeLines: 4): ExpectedResult.pass,
    TestCase(codeLines: 3): ExpectedResult.pass,
    TestCase(codeLines: 4, comments: true): ExpectedResult.pass,

    // --- Exclude config ---
    TestCase(
      codeLines: 5,
      className: _excludedClassName,
      methodName: _excludedMethodName,
    ): ExpectedResult.pass,
    TestCase(
      codeLines: 5,
      className: _excludedClassName,
      methodName: _excludedMethodByDeclaration,
    ): ExpectedResult.pass,
    TestCase(codeLines: 5, methodName: _excludedFunctionName):
        ExpectedResult.pass,
    TestCase(codeLines: 5, methodName: _excludedFunctionByDeclaration):
        ExpectedResult.pass,
    TestCase(
      codeLines: 5,
      className: _nonExcludedClassName,
      methodName: _excludedByString,
    ): ExpectedResult.pass,

    // --- Anonymous functions ---
    TestCase(codeLines: 5, anonymous: true): ExpectedResult.fail,
  };

  @override
  void setUp() {
    rule = FunctionLinesOfCodeRule(
      analysisOptionsLoader: AnalysisOptionsLoader(
        resourceProvider: resourceProvider,
      ),
      parametersParser: FunctionLinesOfCodeParameters.fromJson,
    );
    super.setUp();

    newAnalysisOptionsYamlFile(
      testPackageRootPath,
      '''${analysisOptionsContent(rules: [rule.name])}
$_mockAnalysisOptionsContent''',
    );
  }

  /// Generates test source code for the given [testCase].
  ///
  /// Returns the full [source] to analyze and the [lintTarget] substring
  /// that should trigger the lint diagnostic (for fail cases).
  static ({String source, String lintTarget}) _generateCode(TestCase testCase) {
    final indent = testCase.className != null ? '    ' : '  ';
    final singleComment = testCase.comments
        ? '$indent// This is a single-line comment.\n'
        : '';
    final multiComment = testCase.comments
        ? '\n$indent/*\n$indent * This is a multi-line comment.\n$indent */\n'
        : '';
    final extra = testCase.codeLines - 2;
    final stmts = extra > 0
        ? '\n${repeatLines('${indent}i++;', extra)}\n'
        : '\n';
    final body =
        '$singleComment${indent}var i = 0;$stmts$multiComment\n${indent}return i;\n';

    if (testCase.anonymous) {
      final fn = '() {\n$body}';
      return (source: 'final longAnonymousFunction = $fn;\n', lintTarget: fn);
    }

    final name = testCase.methodName ?? 'function';

    if (testCase.className != null) {
      final method = '  int $name() {\n$body  }';
      return (
        source: '\nclass ${testCase.className} {\n$method\n}\n',
        lintTarget: method,
      );
    }

    final fn = 'int $name() {\n$body}';
    return (source: '$fn\n', lintTarget: fn);
  }

  Future<void> test_function_lines_of_code_cases() async {
    for (final MapEntry(key: testCase, value: expected) in testTable.entries) {
      final (:source, :lintTarget) = _generateCode(testCase);

      try {
        switch (expected) {
          case ExpectedResult.pass:
            await assertNoDiagnostics(source);
          case ExpectedResult.fail:
            final marked = source.replaceFirst(
              lintTarget,
              expectLint(lintTarget),
            );
            await assertAutoDiagnostics(marked);
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
