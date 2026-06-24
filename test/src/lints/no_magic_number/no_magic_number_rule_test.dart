import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:analyzer_testing/utilities/utilities.dart';
import 'package:solid_lints/src/common/parameter_parser/analysis_options_loader.dart';
import 'package:solid_lints/src/lints/no_magic_number/no_magic_number_rule.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../../../lints/auto_test_lint_offsets.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(NoMagicNumberRuleTest);
  });
}

@reflectiveTest
class NoMagicNumberRuleTest extends AnalysisRuleTest with AutoTestLintOffsets {
  static const _importFlutterWidgets = "import 'package:flutter/widgets.dart';";
  static const _mockFlutterWidgetsContent = '''
abstract class Widget {
  const Widget();
}

class SizedBox extends Widget {
  final double? width;
  final Widget? child;
  const SizedBox({this.width, this.child});
}
''';

  @override
  void setUp() {
    rule = NoMagicNumberRule(
      analysisOptionsLoader: AnalysisOptionsLoader(
        resourceProvider: resourceProvider,
      ),
    );
    newPackage('flutter')
      ..addFile('lib/widgets.dart', _mockFlutterWidgetsContent);
    super.setUp();
  }

  Future<void> test_reports_magic_number_in_expression() async {
    await assertAutoDiagnostics('''
int fn(int b) {
  return b + ${expectLint('42')};
}
''');
  }

  Future<void> test_does_not_report_allowed_numbers() async {
    await assertNoDiagnostics(r'''
void fn() {
  var a = 0;
  var b = 1;
  var c = -1;
}
''');
  }

  Future<void> test_does_not_report_consts() async {
    await assertNoDiagnostics(r'''
const pi = 3.14;
void fn() {
  var a = pi;
}
''');
  }

  Future<void> test_does_not_report_in_collections() async {
    await assertNoDiagnostics(r'''
void fn() {
  var list = [1, 2, 3];
  var map = {1: 'a', 2: 'b'};
  var set = {1, 2, 3};
}
''');
  }

  Future<void> test_does_not_report_negative_numbers_in_list() async {
    await assertNoDiagnostics(r'''
void fn() {
  var list = [1, -42, 3];
}
''');
  }

  Future<void> test_does_not_report_negative_numbers_in_set() async {
    await assertNoDiagnostics(r'''
void fn() {
  var set = {-42, -99};
}
''');
  }

  Future<void> test_does_not_report_negative_numbers_in_map() async {
    await assertNoDiagnostics(r'''
void fn() {
  var map = {-42: 'a', 'b': -99};
}
''');
  }

  Future<void> test_reports_widget_params_when_flag_false() async {
    newAnalysisOptionsYamlFile(
      testPackageRootPath,
      analysisOptionsContent(rules: [rule.name]),
    );

    await assertAutoDiagnostics('''
$_importFlutterWidgets

Widget build() {
  return SizedBox(width: ${expectLint('42')});
}
''');
  }

  Future<void> test_does_not_report_widget_params_when_flag_true() async {
    newAnalysisOptionsYamlFile(testPackageRootPath, '''
${analysisOptionsContent(rules: [rule.name])}
plugins:
  solid_lints:
    diagnostics:
      no_magic_number:
        allowed_in_widget_params: true
''');

    await assertNoDiagnostics('''
$_importFlutterWidgets

Widget build() {
  return SizedBox(width: 42);
}
''');
  }

  Future<void> test_does_not_report_in_datetime() async {
    await assertNoDiagnostics(r'''
class DateTime {
  const DateTime(int year, int month, int day);
}
void fn() {
  final apocalypse = DateTime(2012, 12, 21);
}
''');
  }

  Future<void> test_does_not_report_in_enum_constant_arguments() async {
    await assertNoDiagnostics(r'''
enum ConstEnum {
  one(1),
  two(2);

  final int value;
  const ConstEnum(this.value);
}
''');
  }

  Future<void> test_does_not_report_default_formal_parameter_values() async {
    await assertNoDiagnostics(r'''
class DefaultValues {
  final int value;
  DefaultValues.named({this.value = 2});
  DefaultValues.positional([this.value = 3]);
  void methodWithNamedParam({int value = 4}) {}
  void methodWithPositionalParam([int value = 5]) {}
}
void topLevelFunctionWithDefaultParam({int value = 6}) {}
''');
  }

  Future<void> test_does_not_report_in_constructor_initializers() async {
    await assertNoDiagnostics(r'''
class ConstructorInitializer {
  final int value;
  ConstructorInitializer() : value = 10;
}
''');
  }

  Future<void> test_reports_expression_in_constructors_when_not_const() async {
    await assertAutoDiagnostics('''
class TestOperation {
  final double res;
  const TestOperation({required this.res});
}
void fn() {
  TestOperation(res: (${expectLint('5')} / ${expectLint('5')}) * ${expectLint('20')});
}
''');
  }

  Future<void>
  test_does_not_report_expression_in_constructors_when_const() async {
    await assertNoDiagnostics(r'''
class TestOperation {
  final double res;
  const TestOperation({required this.res});
}
void fn() {
  const TestOperation(res: (10 / 2));
}
''');
  }

  Future<void> test_does_not_report_variable_declarations() async {
    await assertNoDiagnostics(r'''
void fn() {
  var x = 42;
  final y = 3.14;
}
''');
  }

  Future<void> test_reports_magic_number_in_variable_expression() async {
    await assertAutoDiagnostics('''
double circumference(double radius) {
  var result = ${expectLint('2')} * ${expectLint('3.14')} * radius;
  return result;
}
''');
  }

  Future<void>
  test_reports_magic_number_in_binary_expression_in_variable() async {
    await assertAutoDiagnostics('''
void fn(int x) {
  var result = x + ${expectLint('42')};
}
''');
  }

  Future<void> test_does_not_report_index_expressions() async {
    await assertNoDiagnostics(r'''
void fn(List<int> list) {
  var x = list[42];
}
''');
  }

  Future<void> test_does_not_report_map_literal_keys_and_values() async {
    await assertNoDiagnostics(r'''
void fn() {
  print({42: 3.14});
}
''');
  }

  Future<void> test_does_not_report_const_map_keys_and_values() async {
    await assertNoDiagnostics(r'''
void fn() {
  const map = {42: 3.14};
}
''');
  }

  Future<void> test_does_not_report_custom_allowed_numbers() async {
    newAnalysisOptionsYamlFile(testPackageRootPath, '''
${analysisOptionsContent(rules: [rule.name])}
plugins:
  solid_lints:
    diagnostics:
      no_magic_number:
        allowed: [42, 100]
''');

    await assertNoDiagnostics(r'''
void fn() {
  print(42);
  print(100);
}
''');
  }

  Future<void> test_does_not_report_in_annotations() async {
    await assertNoDiagnostics(r'''
class Timeout {
  final Duration duration;
  const Timeout(this.duration);
}
class Duration {
  final int seconds;
  const Duration({required this.seconds});
}

@Timeout(Duration(seconds: 30))
void fn() {}
''');
  }
}
