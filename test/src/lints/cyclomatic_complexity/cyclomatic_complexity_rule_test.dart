import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:analyzer_testing/utilities/utilities.dart';
import 'package:solid_lints/src/common/parameter_parser/analysis_options_loader.dart';
import 'package:solid_lints/src/lints/cyclomatic_complexity/cyclomatic_complexity_rule.dart';
import 'package:solid_lints/src/lints/cyclomatic_complexity/models/cyclomatic_complexity_parameters.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(CyclomaticComplexityRuleTest);
  });
}

@reflectiveTest
class CyclomaticComplexityRuleTest extends AnalysisRuleTest {
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
    await assertDiagnostics(
      r'''
void cyclomaticComplexity() {
  if (true) {
    if (true) {
      if (true) {
        if (true) {}
      }
    }
  }
}
''',
      [
        lint(28, 90),
      ],
    );
  }

  Future<void> test_does_not_report_when_complexity_is_within_threshold() async {
    await assertNoDiagnostics(
      r'''
void simple() {
  if (true) {}
}
''',
    );
  }

  Future<void> test_does_not_report_on_excluded_method_in_class() async {
    await assertNoDiagnostics(
      r'''
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
''',
    );
  }

  Future<void> test_does_not_report_on_excluded_top_level_function() async {
    await assertNoDiagnostics(
      r'''
void excludeMethod() {
  if (true) {
    if (true) {
      if (true) {
        if (true) {}
      }
    }
  }
}
''',
    );
  }

  Future<void> test_does_not_report_on_nested_functions() async {
    await assertNoDiagnostics(
      r'''
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
''',
    );
  }

  Future<void> test_reports_when_complexity_exceeds_threshold_with_switch_expression() async {
    await assertDiagnostics(
      r'''
String test(int val) {
  return switch (val) {
    1 => 'one',
    2 => 'two',
    3 => 'three',
    _ => 'other',
  };
}
''',
      [
        lint(21, 100),
      ],
    );
  }

  Future<void> test_reports_when_complexity_exceeds_threshold_due_to_guard_clause() async {
    await assertDiagnostics(
      r'''
String test(int val) {
  return switch (val) {
    1 when val > 0 => 'one',
    2 => 'two',
    _ => 'other',
  };
}
''',
      [
        lint(21, 95),
      ],
    );
  }

  Future<void> test_reports_when_complexity_exceeds_threshold_with_switch_statement_and_patterns() async {
    await assertDiagnostics(
      r'''
void test(Object val) {
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
}
''',
      [
        lint(22, 179),
      ],
    );
  }

  Future<void> test_reports_when_complexity_exceeds_threshold_due_to_logical_operators() async {
    await assertDiagnostics(
      r'''
void test(bool a, bool b, bool c, bool d) {
  if (a && b && c && d) {}
}
''',
      [
        lint(42, 30),
      ],
    );
  }

  Future<void> test_does_not_count_complexity_in_closures() async {
    await assertNoDiagnostics(
      r'''
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
''',
    );
  }
}

