import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:analyzer_testing/utilities/utilities.dart';
import 'package:solid_lints/src/common/parameter_parser/analysis_options_loader.dart';
import 'package:solid_lints/src/lints/number_of_parameters/number_of_parameters_rule.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../../../lints/auto_test_lint_offsets.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(NumberOfParametersRuleTest);
  });
}

@reflectiveTest
class NumberOfParametersRuleTest extends AnalysisRuleTest
    with AutoTestLintOffsets {
  static const _mockAnalysisOptionsContent = '''
plugins:
  solid_lints:
    diagnostics:
      number_of_parameters:
        max_parameters: 2
        exclude:
          - method_name: copyWith
          - class_name: Base
            method_name: myMethod
  ''';

  @override
  void setUp() {
    rule = NumberOfParametersRule(
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

  Future<void> test_reports_on_exceeding_max_parameters() async {
    await assertAutoDiagnostics('''
void fun${expectLint(r'(int a, int b, int c)')} {}
''');
  }

  Future<void> test_does_not_report_on_limit_or_below() async {
    await assertNoDiagnostics(r'''
void fun(int a, int b) {}
void fun2(int a) {}
void fun3() {}
''');
  }

  Future<void> test_does_not_report_on_excluded_copyWith() async {
    await assertNoDiagnostics(r'''
class UserDto {
  UserDto copyWith(int a, int b, int c) {
    return UserDto();
  }
}
''');
  }

  Future<void> test_reports_on_constructors_exceeding_max_parameters() async {
    await assertAutoDiagnostics('''
class Test {
  Test${expectLint(r'(int a, int b, int c)')};
}
''');
  }

  Future<void> test_does_not_report_on_overridden_methods() async {
    await assertNoDiagnostics(r'''
class Base {
  void myMethod(int a, int b, int c) {}
}

class Derived extends Base {
  @override
  void myMethod(int a, int b, int c) {}
}
''');
  }
}
