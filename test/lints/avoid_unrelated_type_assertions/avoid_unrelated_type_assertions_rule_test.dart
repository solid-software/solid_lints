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

  void test_reports_unrelated_is_assertion() async {
    await assertDiagnostics(
      r'''
class Foo {}

class Bar {}

class ChildFoo extends Foo {}

void fun() {
  final testString = '';
  final testList = [1, 2, 3];
  final testMap = {'A': 'B'};
  final Foo foo = Foo();
  final childFoo = ChildFoo();

  final result = testString is int;

  final result2 = testList is List<String>;

  final result3 = foo is Bar;

  final result4 = childFoo is Bar;

  final result5 = testMap['A'] is double;
}
''',
      [
        lint(
          231,
          17,
          messageContainsAll: ['true'],
        ),
        lint(
          269,
          24,
          messageContainsAll: ['true'],
        ),
        lint(
          314,
          10,
          messageContainsAll: ['true'],
        ),
        lint(
          345,
          15,
          messageContainsAll: ['true'],
        ),
        lint(
          381,
          22,
          messageContainsAll: ['true'],
        ),
      ],
    );
  }

  void test_reports_unrelated_is_and_is_not_assertion() async {
    await assertDiagnostics(
      r'''
class _A {}

class _B extends _A {}

class _C {}

void lint() {
  final _A a = _B();

  if (a is _C) return;

  if (a is! _C) return;
}
''',
      [
        lint(
          92,
          7,
          messageContainsAll: ['true'],
        ),
        lint(
          116,
          8,
          messageContainsAll: ['false'],
        ),
      ],
    );
  }
}
