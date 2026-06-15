import 'package:analyzer/src/diagnostic/diagnostic.dart' as diag;
import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:solid_lints/src/lints/avoid_unnecessary_type_casts/avoid_unnecessary_type_casts_rule.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AvoidUnnecessaryTypeCastsRuleTest);
  });
}

@reflectiveTest
class AvoidUnnecessaryTypeCastsRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = AvoidUnnecessaryTypeCastsRule();
    super.setUp();
  }

  @override
  String get analysisRule => rule.name;

  void test_reports_on_list_cast() async {
    await assertDiagnostics(
      r'''
void fun() {
  final testList = [1.0, 2.0, 3.0];

  final result = testList as List<double>;
}
''',
      [
        error(diag.unnecessaryCast, 67, 24),
        lint(67, 24),
      ],
    );
  }

  void test_reports_on_map_value_cast_to_nullable() async {
    await assertDiagnostics(
      r'''
void fun() {
  final testMap = {'A': 'B'};

  final castedMapValue = testMap['A'] as String?;
}
''',
      [
        error(diag.unnecessaryCast, 69, 23),
        lint(69, 23),
      ],
    );
  }

  void test_reports_on_argument_cast() async {
    await assertDiagnostics(
      r'''
void fun() {
  final testString = 'String';

  _testFun(testString as String);
}

void _testFun(String a) {}
''',
      [
        error(diag.unnecessaryCast, 56, 20),
        lint(56, 20),
      ],
    );
  }

  void test_reports_on_parenthesized_cast() async {
    await assertDiagnostics(
      r'''
void fun(String a) {
  final result = (a as String).length;
}
''',
      [
        error(diag.unnecessaryCast, 39, 11),
        lint(39, 11),
      ],
    );
  }

  void test_does_not_report_on_nullable_to_non_nullable_cast() async {
    await assertNoDiagnostics(r'''
void fun() {
  final double? nullableD = 2.0;

  final castedD = nullableD as double;
}
''');
  }

  void test_does_not_report_on_map_value_cast_to_non_nullable() async {
    await assertNoDiagnostics(r'''
void fun() {
  final testMap = {'A': 'B'};

  final castedNotNullMapValue = testMap['A'] as String;
}
''');
  }
}
