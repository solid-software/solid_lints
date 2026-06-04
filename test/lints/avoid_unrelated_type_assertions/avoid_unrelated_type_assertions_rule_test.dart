import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:solid_lints/src/lints/avoid_unrelated_type_assertions/avoid_unrelated_type_assertions_rule.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AvoidUnrelatedTypeAssertionsRuleTest);
  });
}

@reflectiveTest
class AvoidUnrelatedTypeAssertionsRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = AvoidUnrelatedTypeAssertionsRule();
    super.setUp();
  }

  @override
  String get analysisRule => AvoidUnrelatedTypeAssertionsRule.lintName;

  void test_reports_unrelated_string_is_int() async {
    await assertDiagnostics(
      r'''
void fun() {
  final testString = '';

  final result = testString is int;
}
''',
      [
        lint(56, 17, messageContainsAll: ['false']),
      ],
    );
  }

  void test_reports_unrelated_int_list_is_string_list() async {
    await assertDiagnostics(
      r'''
void fun() {
  final testList = [1, 2, 3];

  final result = testList is List<String>;
}
''',
      [
        lint(61, 24, messageContainsAll: ['false']),
      ],
    );
  }

  void test_reports_unrelated_string_map_is_double_map() async {
    await assertDiagnostics(
      r'''
void fun() {
  final testMap = {'A': 'B'};

  final result = testMap['A'] is double;
}
''',
      [
        lint(61, 22, messageContainsAll: ['false']),
      ],
    );
  }

  void test_reports_unrelated_class_is_another_class() async {
    await assertDiagnostics(
      r'''
class Foo {}

class Bar {}

void fun() {
  final Foo foo = Foo();

  final result = foo is Bar;
}
''',
      [
        lint(84, 10, messageContainsAll: ['false']),
      ],
    );
  }

  void test_reports_unrelated_child_class_is_another_class() async {
    await assertDiagnostics(
      r'''
class Foo {}

class Bar {}

class ChildFoo extends Foo {}

void fun() {
  final childFoo = ChildFoo();

  final result = childFoo is Bar;
}
''',
      [
        lint(121, 15, messageContainsAll: ['false']),
      ],
    );
  }

  void test_reports_unrelated_is_condition() async {
    await assertDiagnostics(
      r'''
class _A {}

class _B extends _A {}

class _C {}

void lint() {
  final _A a = _B();

  if (a is _C) return;
}
''',
      [
        lint(92, 7, messageContainsAll: ['false']),
      ],
    );
  }

  void test_reports_unrelated_is_not_condition() async {
    await assertDiagnostics(
      r'''
class _A {}

class _B extends _A {}

class _C {}

void lint() {
  final _A a = _B();

  if (a is! _C) return;
}
''',
      [
        lint(92, 8, messageContainsAll: ['true']),
      ],
    );
  }
}
