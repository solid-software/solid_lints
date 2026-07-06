import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:solid_lints/src/lints/avoid_non_null_assertion/avoid_non_null_assertion_rule.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../auto_test_lint_offsets.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AvoidNonNullAssertionRuleTest);
  });
}

@reflectiveTest
class AvoidNonNullAssertionRuleTest extends AnalysisRuleTest
    with AutoTestLintOffsets {
  @override
  void setUp() {
    rule = AvoidNonNullAssertionRule();
    super.setUp();
  }

  Future<void> test_reports_non_null_assertion_on_nullable_value() async {
    await assertAutoDiagnostics('''
void m(int? number) {
  final value = ${expectLint('number!')};
}
''');
  }

  Future<void> test_reports_non_null_assertion_on_method_call() async {
    await assertAutoDiagnostics('''
void m(Object? object) {
  ${expectLint('object!')}.toString();
}
''');
  }

  Future<void> test_does_not_report_map_access() async {
    await assertNoDiagnostics(r'''
void m() {
  final map = {'key': 'value'};
  map['key']!;
}
''');
  }

  Future<void> test_does_not_report_safe_null_check() async {
    await assertNoDiagnostics(r'''
void m(int? number) {
  if (number != null) {
    final value = number;
  }
}
''');
  }
}
