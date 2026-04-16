import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:solid_lints/src/lints/avoid_late_keyword/avoid_late_keyword_rule.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AvoidLateKeywordRuleTest);
  });
}

@reflectiveTest
class AvoidLateKeywordRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = AvoidLateKeywordRule();
    super.setUp();
  }

  void test_reports_uninitialized_late_field() async {
    await assertDiagnostics(
      r'''
class Test {
  late final int field;
}
''',
      [lint(30, 5)],
    );
  }

  void test_reports_uninitialized_late_local_variable() async {
    await assertDiagnostics(
      r'''
void m() {
  late final String value;
}
''',
      [lint(31, 5)],
    );
  }

  void test_does_not_report_initialized_late_variable() async {
    await assertNoDiagnostics(r'''
class Test {
  late final int field = 1;
}
''');
  }

  void test_does_not_report_non_late_variable() async {
    await assertNoDiagnostics(r'''
class Test {
  final int field = 1;
}
''');
  }
}
