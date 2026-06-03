import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:solid_lints/src/lints/avoid_unnecessary_return_variable/avoid_unnecessary_return_variable_rule.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AvoidUnnecessaryReturnVariableTest);
  });
}

@reflectiveTest
class AvoidUnnecessaryReturnVariableTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = AvoidUnnecessaryReturnVariableRule();
    super.setUp();
  }

  @override
  String get analysisRule => AvoidUnnecessaryReturnVariableRule.lintName;

  void test_does_not_report_if_return_good_trivial() async {
    await assertNoDiagnostics(
      r'''
int returnVarTestTrivial() {
  return 1;
}
  ''',
    );
  }

  void test_does_not_report_if_return_is_mutable() async {
    await assertNoDiagnostics(
      r'''
int returnVarTestMutable() {
  var a = 1;
  a++;

  return a;
}
  ''',
    );
  }

  void test_does_not_report_if_returns_parameter() async {
    await assertNoDiagnostics(
      r'''
int returnVarTestReturnParameter(int param) {
  return param;
}
  ''',
    );
  }

  void test_does_not_report_if_return_is_cached_mutable() async {
    await assertNoDiagnostics(
      r'''
int returnVarTestCachedMutable() {
  var a = 1;
  final result = a;
  _doNothing();

  return result;
}

void _doNothing() {}
  ''',
    );
  }

  void test_reports_if_return_follows_declaration() async {
    await assertDiagnostics(r'''
int returnVarTestReturnFollowsDeclaration() {
  var a = 1;
  final result = a;

  //Some comment here

  return result;
}
  ''', [lint(105, 14)]);
  }

  void test_does_not_report_if_return_is_cached_another_method_result() async {
    await assertNoDiagnostics(
      r'''
int returnVarTestCachedAnotherMethodResult() {
  var a = 1;
  final result = _testValueEval();
  _doNothing();

  return result;
}

int _testValueEval() {
  return 1;
}

void _doNothing() {}
''',
    );
  }

  void test_does_not_report_if_return_is_cached_object_field() async {
    await assertNoDiagnostics(
      r'''
int returnVarTestCachedObjectField() {
  final obj = _TestClass();
  final result = obj.varField;
  _doNothing();

  return result;
}

class _TestClass {
  static const constValue = 1;
  static final finalValue = 1;
  //ignore: member_ordering
  final finalField = 1;
  var varField = 1;
}

void _doNothing() {}
''',
    );
  }

  void test_does_not_report_if_return_used_variable() async {
    await assertNoDiagnostics(
      r'''
int returnVarTestUsedVariable() {
  var a = 1;
  final result = 2;
  a += result;

  return result;
}
''',
    );
  }

  void test_reports_if_return_is_bad_trivial() async {
    await assertDiagnostics(r'''
int returnVarTestBadTrivial() {
  final result = 1;

  return result;
}
''', [lint(55, 14)]);
  }

  void test_reports_if_return_is_bad_immutable_expression() async {
    await assertDiagnostics(r'''
int returnVarTestBadImmutableExpression() {
  const constLocal = 1;
  final finalLocal = 1;
  final testObj = _TestClass();
  final result = constLocal +
      finalLocal +
      1 + //const literal
      _TestClass.constValue +
      _TestClass.finalValue +
      testObj.finalField;
  _doNothing();

  return result;
}

class _TestClass {
  static const constValue = 1;
  static final finalValue = 1;
  //ignore: member_ordering
  final finalField = 1;
  var varField = 1;
}

void _doNothing() {}
''', [lint(304, 14)]);
  }
}
