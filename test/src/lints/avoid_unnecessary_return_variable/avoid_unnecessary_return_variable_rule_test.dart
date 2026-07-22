import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:solid_lints/src/lints/avoid_unnecessary_return_variable/avoid_unnecessary_return_variable_rule.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../../utils/auto_test_lint_offsets.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AvoidUnnecessaryReturnVariableTest);
  });
}

@reflectiveTest
class AvoidUnnecessaryReturnVariableTest extends AnalysisRuleTest
    with AutoTestLintOffsets {
  @override
  void setUp() {
    rule = AvoidUnnecessaryReturnVariableRule();
    super.setUp();
  }

  Future<void> test_does_not_report_if_return_good_trivial() async {
    await assertNoDiagnostics(r'''
int returnVarTestTrivial() {
  return 1;
}
''');
  }

  Future<void> test_does_not_report_if_return_is_mutable() async {
    await assertNoDiagnostics(r'''
int returnVarTestMutable() {
  var a = 1;
  a++;

  return a;
}
''');
  }

  Future<void> test_does_not_report_if_returns_parameter() async {
    await assertNoDiagnostics(r'''
int returnVarTestReturnParameter(int param) {
  return param;
}
''');
  }

  Future<void> test_does_not_report_if_return_is_cached_mutable() async {
    await assertNoDiagnostics(r'''
int returnVarTestCachedMutable() {
  var a = 1;
  final result = a;
  _doNothing();

  return result;
}

void _doNothing() {}
''');
  }

  Future<void> test_reports_if_return_follows_declaration() async {
    await assertAutoDiagnostics('''
int returnVarTestReturnFollowsDeclaration() {
  var a = 1;
  final result = a;

  //Some comment here

  ${expectLint('return result;')}
}
''');
  }

  Future<void>
  test_does_not_report_if_return_is_cached_another_method_result() async {
    await assertNoDiagnostics(r'''
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
''');
  }

  Future<void> test_does_not_report_if_return_is_cached_object_field() async {
    await assertNoDiagnostics(r'''
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
''');
  }

  Future<void> test_does_not_report_if_return_used_variable() async {
    await assertNoDiagnostics(r'''
int returnVarTestUsedVariable() {
  var a = 1;
  final result = 2;
  a += result;

  return result;
}
''');
  }

  Future<void> test_reports_if_return_is_bad_trivial() async {
    await assertAutoDiagnostics('''
int returnVarTestBadTrivial() {
  final result = 1;

  ${expectLint('return result;')}
}
''');
  }

  Future<void> test_reports_if_return_is_bad_immutable_expression() async {
    await assertAutoDiagnostics('''
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

  ${expectLint('return result;')}
}

class _TestClass {
  static const constValue = 1;
  static final finalValue = 1;
  //ignore: member_ordering
  final finalField = 1;
  var varField = 1;
}

void _doNothing() {}
''');
  }

  Future<void> test_does_not_report_if_return_is_cached_nested_block() async {
    await assertNoDiagnostics(r'''
Future<String?> testAvoidUnnecessaryReturnVariableNestedBlock() async {
  final cached = 'cached';
  if (cached.isNotEmpty) {
    // Should NOT trigger the avoid_unnecessary_return_variable lint
    return cached;
  }
  return null;
}
''');
  }

  Future<void>
  test_reports_if_return_is_cached_and_only_returned_nested_block() async {
    await assertAutoDiagnostics('''
int test(bool b) {
  final a = 3;
  if (b) {
    ${expectLint('return a;')}
  }
  return 0;
}
''');
  }

  Future<void> test_reports_if_return_in_parentheses() async {
    await assertAutoDiagnostics('''
int test() {
  final a = 3;
  ${expectLint('return (a);')}
}
''');
  }

  Future<void>
  test_does_not_report_if_cached_and_used_after_nested_block() async {
    await assertNoDiagnostics(r'''
int test(bool b) {
  final a = 3;
  if (b) {
    return a;
  }
  return a + 1;
}
''');
  }

  void test_does_not_report_if_type_promoted() async {
    await assertNoDiagnostics(r'''
class Test {
  final Map<String, Object> _map = {};

  T get<T>(String key) {
    final value = _map[key];
    if (value is T) {
      // local variable is promoted to T
      return value;
    }

    throw Exception('value is not of type $T');
  }
}
''');
  }

  void test_does_not_report_if_used_in_other_return_statement() async {
    await assertNoDiagnostics(r'''
String test(bool someCondition) {
  final a = 'test';
  if (someCondition) return a;

  return 'something $a';
}
''');
  }
}
