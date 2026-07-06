import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:solid_lints/src/lints/avoid_unrelated_type_assertions/avoid_unrelated_type_assertions_rule.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../auto_test_lint_offsets.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AvoidUnrelatedTypeAssertionsRuleTest);
  });
}

@reflectiveTest
class AvoidUnrelatedTypeAssertionsRuleTest extends AnalysisRuleTest
    with AutoTestLintOffsets {
  @override
  void setUp() {
    rule = AvoidUnrelatedTypeAssertionsRule();
    super.setUp();
  }

  Future<void> test_reports_unrelated_string_is_int() async {
    await assertAutoDiagnostics('''
void fun() {
  final testString = '';

  final result = ${expectLint('testString is int', messageContainsAll: ['false'])};
}
''');
  }

  Future<void> test_reports_unrelated_int_list_is_string_list() async {
    await assertAutoDiagnostics('''
void fun() {
  final testList = [1, 2, 3];

  final result = ${expectLint('testList is List<String>', messageContainsAll: ['false'])};
}
''');
  }

  Future<void> test_reports_unrelated_string_map_is_double_map() async {
    await assertAutoDiagnostics('''
void fun() {
  final testMap = {'A': 'B'};

  final result = ${expectLint("testMap['A'] is double", messageContainsAll: ['false'])};
}
''');
  }

  Future<void> test_reports_unrelated_class_is_another_class() async {
    await assertAutoDiagnostics('''
class Foo {}

class Bar {}

void fun() {
  final Foo foo = Foo();

  final result = ${expectLint('foo is Bar', messageContainsAll: ['false'])};
}
''');
  }

  Future<void> test_reports_unrelated_child_class_is_another_class() async {
    await assertAutoDiagnostics('''
class Foo {}

class Bar {}

class ChildFoo extends Foo {}

void fun() {
  final childFoo = ChildFoo();

  final result = ${expectLint('childFoo is Bar', messageContainsAll: ['false'])};
}
''');
  }

  Future<void> test_reports_unrelated_is_condition() async {
    await assertAutoDiagnostics('''
class _A {}

class _B extends _A {}

class _C {}

void lint() {
  final _A a = _B();

  if (${expectLint('a is _C', messageContainsAll: ['false'])}) return;
}
''');
  }

  Future<void> test_reports_unrelated_is_not_condition() async {
    await assertAutoDiagnostics('''
class _A {}

class _B extends _A {}

class _C {}

void lint() {
  final _A a = _B();

  if (${expectLint('a is! _C', messageContainsAll: ['true'])}) return;
}
''');
  }
}
