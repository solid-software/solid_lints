import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:solid_lints/src/lints/avoid_unnecessary_type_assertions/avoid_unnecessary_type_assertions_rule.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../auto_test_lint_offsets.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AvoidUnnecessaryTypeAssertionsRuleTest);
  });
}

@reflectiveTest
class AvoidUnnecessaryTypeAssertionsRuleTest extends AnalysisRuleTest
    with AutoTestLintOffsets {
  @override
  void setUp() {
    rule = AvoidUnnecessaryTypeAssertionsRule();
    super.setUp();
  }

  @override
  String get analysisRule => AvoidUnnecessaryTypeAssertionsRule.lintName;

  Future<void>
  test_does_not_report_if_is_expression_checks_nullable_source() async {
    await assertNoDiagnostics(r'''
void fun() {
  final double? nullableD = 2.0;
  final castedD = nullableD is double;
}
''');
  }

  Future<void>
  test_does_not_report_if_is_not_expression_checks_unrelated_subtype() async {
    await assertNoDiagnostics(r'''
class _A {}

class _B extends _A {}

class _C extends _A {}

void fun() {
  final _A a = _B();
  if (a is! _C) return;
}
''');
  }

  Future<void>
  test_does_not_report_if_is_expression_has_different_generic_type_argument() async {
    await assertNoDiagnostics(r'''
void fun() {
  final nums = <num>[1, 2, 3];
  final result = nums is List<double>;
}
''');
  }

  Future<void>
  test_does_not_report_if_where_type_filters_dynamic_iterable() async {
    await assertNoDiagnostics(r'''
void fun() {
  final dynamicList = <dynamic>[1.0, 2.0];
  dynamicList.whereType<double>();
}
''');
  }

  Future<void>
  test_does_not_report_if_where_type_has_different_generic_type_argument() async {
    await assertNoDiagnostics(r'''
void fun() {
  final nums = <num>[1, 2, 3];
  nums.whereType<double>();
}
''');
  }

  Future<void> test_does_not_report_if_where_type_omits_type_argument() async {
    await assertNoDiagnostics(r'''
void fun() {
  final values = [1.0, 2.0, 3.0];
  values.whereType();
}
''');
  }

  Future<void> test_reports_if_is_expression_checks_exact_generic_type() async {
    await assertAutoDiagnostics('''
// ignore_for_file: unnecessary_type_check

void fun() {
  final testList = [1.0, 2.0, 3.0];
  final result = ${l('testList is List<double>')};
}
''');
  }

  Future<void>
  test_reports_if_is_not_expression_checks_exact_generic_type() async {
    await assertAutoDiagnostics('''
// ignore_for_file: unnecessary_type_check

void fun() {
  final testList = [1.0, 2.0, 3.0];
  final result = ${l('testList is! List<double>')};
}
''');
  }

  Future<void> test_reports_if_is_expression_checks_exact_scalar_type() async {
    await assertAutoDiagnostics('''
// ignore_for_file: unnecessary_type_check

void fun() {
  final double d = 2.0;
  final casted = ${l('d is double')};
}
''');
  }

  Future<void>
  test_reports_if_is_not_expression_checks_exact_scalar_type() async {
    await assertAutoDiagnostics('''
// ignore_for_file: unnecessary_type_check

void fun() {
  final double d = 2.0;
  final negativeCasted = ${l('d is! double')};
}
''');
  }

  Future<void> test_reports_if_is_expression_checks_nullable_target() async {
    await assertAutoDiagnostics('''
// ignore_for_file: unnecessary_type_check

void fun() {
  final double d = 2.0;
  final casted = ${l('d is double?')};
}
''');
  }

  Future<void> test_reports_if_is_expression_checks_supertype() async {
    await assertAutoDiagnostics('''
// ignore_for_file: unnecessary_type_check

void fun() {
  final ints = <int>[1, 2, 3];
  final result = ${l('ints is Iterable<int>')};
}
''');
  }

  Future<void> test_reports_if_where_type_filters_exact_type() async {
    await assertAutoDiagnostics('''
void fun() {
  final testList = [1.0, 2.0, 3.0];
  ${l('testList.whereType<double>()')}.length;
}
''');
  }

  Future<void> test_reports_if_where_type_filters_nullable_type() async {
    await assertAutoDiagnostics('''
void fun() {
  ${l('[1.0, 2.0].whereType<double?>()')};
}
''');
  }

  Future<void> test_reports_on_custom_types_with_default_generics() async {
    await assertAutoDiagnostics('''
// ignore_for_file: unnecessary_type_check

abstract class MyIterable implements Iterable<int> {}

void test(MyIterable iterable) {
  ${l('iterable.whereType<num>()')};
}
''');
  }

  Future<void> test_does_not_report_custom_types_when_using_subtype() async {
    await assertNoDiagnostics(r'''
abstract class _A {}
abstract class _B extends _A {}

abstract class AIterable implements Iterable<_A> {}

void test(AIterable iterable) {
  iterable.whereType<_B>();
}
''');
  }
}
