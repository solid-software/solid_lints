import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:analyzer_testing/utilities/utilities.dart';
import 'package:solid_lints/src/common/parameter_parser/analysis_options_loader.dart';
import 'package:solid_lints/src/lints/function_lines_of_code/function_lines_of_code_rule.dart';
import 'package:solid_lints/src/lints/function_lines_of_code/models/function_lines_of_code_parameters.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(FunctionLinesOfCodeRuleTest);
  });
}

@reflectiveTest
class FunctionLinesOfCodeRuleTest extends AnalysisRuleTest {
  static const _mockAnalysisOptionsContent = '''
plugins:
  solid_lints:
    diagnostics:
      function_lines_of_code:
        max_lines: 4
        exclude:
          - class_name: ClassWithLongMethods
            method_name: longMethodExcluded
          - method_name: longMethodExcludedByDeclarationName
          - method_name: longFunctionExcluded
          - method_name: longFunctionExcludedByDeclarationName
          - longMethodExcludedByString
  ''';

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

  Future<void> test_reports_when_lines_exceed_threshold() async {
    await assertDiagnostics(
      r'''
int longFunction() {
  var i = 0;
  i++;
  i++;
  i++;

  return i;
}
''',
      [lint(0, 69)],
    );
  }

  Future<void> test_does_not_report_when_lines_within_threshold() async {
    await assertNoDiagnostics(r'''
int shortFunction() {
  var i = 0;
  i++;
  i++;

  return i;
}
''');
  }

  Future<void> test_does_not_report_on_excluded_method() async {
    await assertNoDiagnostics(r'''
class ClassWithLongMethods {
  int longMethodExcluded() {
    var i = 0;
    i++;
    i++;
    i++;

    return i;
  }
}
''');
  }

  Future<void> test_does_not_report_on_excluded_top_level_function() async {
    await assertNoDiagnostics(r'''
int longFunctionExcluded() {
  var i = 0;
  i++;
  i++;
  i++;

  return i;
}
''');
  }

  Future<void> test_reports_on_anonymous_functions() async {
    await assertDiagnostics(
      r'''
final longAnonymousFunction = () {
  var i = 0;
  i++;
  i++;
  i++;

  return i;
};
''',
      [lint(30, 53)],
    );
  }

  Future<void> test_does_not_report_on_method_excluded_by_string() async {
    await assertNoDiagnostics(r'''
class SomeClass {
  int longMethodExcludedByString() {
    var i = 0;
    i++;
    i++;
    i++;

    return i;
  }
}
''');
  }
}
