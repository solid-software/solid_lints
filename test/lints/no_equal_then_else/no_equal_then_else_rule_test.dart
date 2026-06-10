import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:solid_lints/src/lints/no_equal_then_else/no_equal_then_else_rule.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(NoEqualThenElseRuleTest);
  });
}

@reflectiveTest
class NoEqualThenElseRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = NoEqualThenElseRule();
    super.setUp();
  }

  @override
  String get analysisRule => rule.name;

  void test_reports_then_and_else_equal() async {
    await assertDiagnostics(
      r'''
void fun() {
  final _valueA = 1;
  final _valueB = 2;

  int _result = 0;

  if (_valueA == 1) {
    _result = _valueA;
  } else {
    _result = _valueA;
  }
}
''',
      [lint(78, 80)],
    );
  }

  void test_does_not_report_then_and_else_different() async {
    await assertNoDiagnostics(r'''
void fun() {
  final _valueA = 1;
  final _valueB = 2;

  int _result = 0;

  if (_valueA == 1) {
    _result = _valueA;
  } else {
    _result = _valueB;
  }
}
''');
  }

  void test_reports_conditional_expression_then_and_else_equal() async {
    await assertDiagnostics(
      r'''
void fun() {
  final _valueA = 1;
  final _valueB = 2;

  int _result = 0;

  _result = _valueA == 2 ? _valueA : _valueA;
}
''',
      [lint(88, 32)],
    );
  }

  void
  test_does_not_report_conditional_expression_then_and_else_different() async {
    await assertNoDiagnostics(r'''
void fun() {
  final _valueA = 1;
  final _valueB = 2;

  int _result = 0;

  _result = _valueA == 2 ? _valueA : _valueB;
}
''');
  }
}
