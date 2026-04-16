import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:solid_lints/src/lints/prefer_early_return/prefer_early_return_rule.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(PreferEarlyReturnRuleTest);
  });
}

@reflectiveTest
class PreferEarlyReturnRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = PreferEarlyReturnRule();
    super.setUp();
  }

  @override
  String get analysisRule => PreferEarlyReturnRule.lintName;

  void test_reports_if_as_only_statement_in_function() async {
    await assertDiagnostics(
      r'''
void test(bool a) {
  if (a) {
    print('hello');
  }
}
''',
      [lint(22, 32)],
    );
  }

  void test_reports_nested_if_as_only_statement() async {
    await assertDiagnostics(
      r'''
void test(bool a, bool b) {
  if (a) {
    if (b) {
      print('nested');
    }
  }
}
''',
      [
        lint(30, 54),
        lint(43, 37),
      ],
    );
  }

  void test_does_not_report_if_with_following_statement() async {
    await assertNoDiagnostics(
      r'''
void test(bool a) {
  if (a) {
    print('hello');
  }

  print('after');
}
''',
    );
  }

  void test_does_not_report_when_multiple_statements_exist() async {
    await assertNoDiagnostics(
      r'''
void test(bool a) {
  print('before');

  if (a) {
    print('hello');
  }
}
''',
    );
  }

  void test_does_not_report_regular_inline_if() async {
    await assertNoDiagnostics(
      r'''
void test(bool a) {
  if (a) print('hello');
  print('done');
}
''',
    );
  }
}
