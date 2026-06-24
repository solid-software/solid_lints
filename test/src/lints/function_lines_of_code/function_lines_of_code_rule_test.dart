import 'package:analyzer_testing/utilities/utilities.dart';
import 'package:solid_lints/src/common/parameter_parser/analysis_options_loader.dart';
import 'package:solid_lints/src/lints/function_lines_of_code/function_lines_of_code_rule.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../../utils/code_generators.dart';
import '../../utils/table_driven_rule_test_base.dart';
import 'models/test_case.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(FunctionLinesOfCodeRuleTest);
  });
}

@reflectiveTest
class FunctionLinesOfCodeRuleTest extends TableDrivenRuleTest<TestCase> {
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
    );
    super.setUp();

    newAnalysisOptionsYamlFile(
      testPackageRootPath,
      '''${analysisOptionsContent(rules: [rule.name])}
$_mockAnalysisOptionsContent''',
    );
  }

  /// Generates test source code for the given [testCase] based on [expected].
  @override
  String generateCode(TestCase testCase, ExpectedResult expected) {
    final indent = testCase.className != null ? '    ' : '  ';

    final bodyBuffer = StringBuffer();
    if (testCase.comments) {
      bodyBuffer.writeln('$indent// This is a single-line comment.');
    }

    bodyBuffer.writeln('${indent}var i = 0;');

    final extra = testCase.codeLines - 2;
    if (extra > 0) {
      bodyBuffer.writeln('${indent}i++;'.repeatLines(extra));
    }

    if (testCase.comments) {
      bodyBuffer.writeln('$indent/*');
      bodyBuffer.writeln('$indent * This is a multi-line comment.');
      bodyBuffer.writeln('$indent */');
    }

    bodyBuffer.write('${indent}return i;\n');
    final body = bodyBuffer.toString();

    String wrap(String target) {
      return expected == ExpectedResult.fail ? expectLint(target) : target;
    }

    if (testCase.anonymous) {
      final fn = '() {\n$body}';
      return 'final longAnonymousFunction = ${wrap(fn)};\n';
    }

    final name = testCase.methodName ?? 'function';

    if (testCase.className != null) {
      final method = '  int $name() {\n$body  }';
      return '\nclass ${testCase.className} {\n${wrap(method)}\n}\n';
    }

    final fn = 'int $name() {\n$body}';
    return '${wrap(fn)}\n';
  }

  Future<void> test_function_lines_of_code_cases() async {
    await runTableTests(testTable);
  }
}
