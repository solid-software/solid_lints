import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:analyzer_testing/utilities/utilities.dart';
import 'package:solid_lints/src/common/parameter_parser/analysis_options_loader.dart';
import 'package:solid_lints/src/lints/cyclomatic_complexity/cyclomatic_complexity_rule.dart';
import 'package:solid_lints/src/lints/cyclomatic_complexity/models/cyclomatic_complexity_parameters.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../../../lints/auto_test_lint_offsets.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(CyclomaticComplexityRuleTest);
  });
}

@reflectiveTest
class CyclomaticComplexityRuleTest extends AnalysisRuleTest
    with AutoTestLintOffsets {
  static const _mockAnalysisOptionsContent = '''
plugins:
  solid_lints:
    diagnostics:
      cyclomatic_complexity:
        max_complexity: 4
        exclude:
          - class_name: Exclude
            method_name: excludeMethod
          - method_name: excludeMethod
  ''';

  @override
  void setUp() {
    rule = CyclomaticComplexityRule(
      analysisOptionsLoader: AnalysisOptionsLoader(
        resourceProvider: resourceProvider,
      ),
      parametersParser: CyclomaticComplexityParameters.fromJson,
    );
    super.setUp();

    newAnalysisOptionsYamlFile(
      testPackageRootPath,
      '''${analysisOptionsContent(rules: [rule.name])}
$_mockAnalysisOptionsContent''',
    );
  }

  @override
  String get analysisRule => CyclomaticComplexityRule.lintName;

  Future<void> test_reports_when_complexity_exceeds_threshold() async {
    await assertAutoDiagnostics('''
void cyclomaticComplexity() ${expectLint(r'''{
  if (true) {
    if (true) {
      if (true) {
        if (true) {}
      }
    }
  }
}''')}
''');
  }

  Future<void> test_does_not_report_when_complexity_is_within_threshold() async {
    await assertNoDiagnostics(r'''
void simple() {
  if (true) {}
}
''');
  }

  Future<void> test_does_not_report_on_excluded_method_in_class() async {
    await assertNoDiagnostics(r'''
class Exclude {
  void excludeMethod() {
    if (true) {
      if (true) {
        if (true) {
          if (true) {}
        }
      }
    }
  }
}
''');
  }

  Future<void> test_does_not_report_on_excluded_top_level_function() async {
    await assertNoDiagnostics(r'''
void excludeMethod() {
  if (true) {
    if (true) {
      if (true) {
        if (true) {}
      }
    }
  }
}
''');
  }

  Future<void> test_does_not_report_on_nested_functions() async {
    await assertNoDiagnostics(r'''
void parentFunction() {
  if (true) {}
  
  void nestedFunction() {
    if (true) {
      if (true) {
        if (true) {}
      }
    }
  }
}
''');
  }

  Future<void> test_reports_when_complexity_exceeds_threshold_with_switch_expression() async {
    await assertAutoDiagnostics('''
String test(int val) ${expectLint(r'''{
  return switch (val) {
    1 => 'one',
    2 => 'two',
    3 => 'three',
    _ => 'other',
  };
}''')}
''');
  }

  Future<void> test_reports_when_complexity_exceeds_threshold_due_to_guard_clause() async {
    await assertAutoDiagnostics('''
String test(int val) ${expectLint(r'''{
  return switch (val) {
    1 when val > 0 => 'one',
    2 => 'two',
    _ => 'other',
  };
}''')}
''');
  }

  Future<void> test_reports_when_complexity_exceeds_threshold_with_switch_statement_and_patterns() async {
    await assertAutoDiagnostics('''
void test(Object val) ${expectLint(r'''{
  switch (val) {
    case int x:
      print('int');
    case String s:
      print('string');
    case double d:
      print('double');
    default:
      print('other');
  }
}''')}
''');
  }

  Future<void> test_reports_when_complexity_exceeds_threshold_due_to_logical_operators() async {
    await assertAutoDiagnostics('''
void test(bool a, bool b, bool c, bool d) ${expectLint(r'''{
  if (a && b && c && d) {}
}''')}
''');
  }

  Future<void> test_does_not_count_complexity_in_closures() async {
    await assertNoDiagnostics(r'''
void main() {
  Calculator? calc;
  group('a', () {
    group('b', () {
      group('c', () {
        test('adds one to input values', () {
          calc = Calculator();
          expect(calc?.addOne(2), 3);
          expect(calc?.addOne(-7), -6);
          expect(calc?.addOne(0), 1);
        });
      });
    });
  });
}
void group(String name, void Function() body) {}
void test(String name, void Function() body) {}
void expect(Object? actual, Object? matcher) {}
class Calculator {
  int addOne(int value) => value + 1;
}
''');
  }

  Future<void> test_reports_when_constructor_complexity_exceeds_threshold() async {
    await assertAutoDiagnostics('''
class Complex {
  Complex(int val) ${expectLint(r'''{
    if (val > 0) {
      if (val > 1) {
        if (val > 2) {
          if (val > 3) {}
        }
      }
    }
  }''')}
}
''');
  }

  Future<void> test_does_not_report_on_simple_constructor() async {
    await assertNoDiagnostics(r'''
class Simple {
  Simple(int val) {
    if (val > 0) {}
  }
}
''');
  }

  Future<void> test_reports_when_complexity_exceeds_threshold_with_do_statement() async {
    await assertAutoDiagnostics('''
void testDoWhile() ${expectLint(r'''{
  int x = 0;
  do {
    if (x == 1) {
      if (x == 2) {
        if (x == 3) {}
      }
    }
  } while (x < 10);
}''')}
''');
  }

  Future<void>
      test_reports_when_complexity_exceeds_threshold_due_to_collection_if() async {
    await assertAutoDiagnostics('''
void test(bool a, bool b, bool c, bool d) ${expectLint(r'''{
  var result = [
    if (a) 1,
    if (b) 2,
    if (c) 3,
    if (d) 4,
  ];
}''')}
''');
  }

  Future<void>
      test_reports_when_complexity_exceeds_threshold_due_to_collection_for() async {
    await assertAutoDiagnostics('''
void test(List<int> l1, List<int> l2, List<int> l3, List<int> l4) ${expectLint(r'''{
  var result = [
    for (var x in l1) x,
    for (var x in l2) x,
    for (var x in l3) x,
    for (var x in l4) x,
  ];
}''')}
''');
  }

  Future<void>
      test_reports_when_complexity_exceeds_threshold_due_to_logical_and_pattern() async {
    await assertAutoDiagnostics('''
void test(Object val) ${expectLint(r'''{
  if (val case int x && > 0 && < 10 && != 5 && != 6) {}
}''')}
''');
  }

  Future<void>
      test_reports_when_complexity_exceeds_threshold_due_to_logical_or_pattern() async {
    await assertAutoDiagnostics('''
void test(Object val) ${expectLint(r'''{
  if (val case int x || int x || int x || int x || int x) {}
}''')}
''');
  }

  Future<void>
      test_reports_when_complexity_exceeds_threshold_due_to_null_aware_cascade() async {
    await assertAutoDiagnostics('''
void test(dynamic a, dynamic b, dynamic c, dynamic d) ${expectLint(r'''{
  a?..f();
  b?..f();
  c?..f();
  d?..f();
}''')}
''');
  }

  Future<void>
      test_reports_when_complexity_exceeds_threshold_due_to_null_aware_spread() async {
    await assertAutoDiagnostics('''
void test(List? a, List? b, List? c, List? d) ${expectLint(r'''{
  var r = [
    ...?a,
    ...?b,
    ...?c,
    ...?d,
  ];
}''')}
''');
  }

  Future<void> test_does_not_report_on_normal_cascades_and_spreads() async {
    await assertNoDiagnostics(r'''
void test(dynamic x, List<int> y) {
  x..a()..b();
  [...y];
}
''');
  }

  Future<void>
      test_does_not_report_when_collection_elements_within_threshold() async {
    await assertNoDiagnostics(r'''
void test(bool a, List<int> list) {
  var result = [
    if (a) 1,
    for (var x in list) x,
  ];
}
''');
  }

  Future<void> test_does_not_double_count_cascade_sections() async {
    await assertNoDiagnostics(r'''
void test(dynamic x) {
  x?..a()..b()..c()..d()..e();
}
''');
  }

  Future<void> test_does_not_report_on_simple_pattern_matching() async {
    await assertNoDiagnostics(r'''
void test(Object val) {
  if (val case int x && > 0) {}
}
''');
  }

  Future<void>
      test_does_not_report_on_pattern_matching_or_within_threshold() async {
    await assertNoDiagnostics(r'''
void test(Object val) {
  if (val case int x || int x) {}
}
''');
  }

  Future<void> test_does_not_count_collection_elements_in_closures() async {
    await assertNoDiagnostics(r'''
void parent() {
  final closure = () {
    final list = [
      if (true) 1,
      if (true) 2,
      if (true) 3,
      if (true) 4,
    ];
  };
}
''');
  }

  Future<void>
      test_does_not_count_null_aware_cascades_and_spreads_in_closures() async {
    await assertNoDiagnostics(r'''
void parent() {
  final closure = (dynamic x, List? y) {
    x?..a()..b()..c()..d();
    [...?y];
  };
}
''');
  }
}
