import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:analyzer_testing/utilities/utilities.dart';
import 'package:solid_lints/src/common/parameter_parser/analysis_options_loader.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/avoid_duplicate_code_rule.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../../../lints/auto_test_lint_offsets.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AvoidDuplicateCodeRuleTest);
  });
}

@reflectiveTest
class AvoidDuplicateCodeRuleTest extends AnalysisRuleTest
    with AutoTestLintOffsets {
  static const _mockAnalysisOptionsContent = '''
plugins:
  solid_lints:
    diagnostics:
      avoid_duplicate_code:
        min_statements: 3
        check_blocks: true
        exclude:
          - method_name: excluded
  ''';

  @override
  void setUp() {
    rule = AvoidDuplicateCodeRule(
      analysisOptionsLoader: AnalysisOptionsLoader(
        resourceProvider: resourceProvider,
      ),
    );
    super.setUp();

    newAnalysisOptionsYamlFile(
      testPackageRootPath,
      '''${analysisOptionsContent(rules: [rule.name])}
$_mockAnalysisOptionsContent''',
    );
  }

  // --- Base Tests (min_statements: 3, check_blocks: true, default) ---

  Future<void>
  test_reports_when_two_functions_have_identical_bodies() async {
    await assertAutoDiagnostics('''
void first() {
  final x = 1;
  if (x > 0) {
    print(x);
  }
  print('done');
}

${expectLint(r'''void second() {
  final x = 1;
  if (x > 0) {
    print(x);
  }
  print('done');
}''')}
''');
  }

  Future<void>
  test_reports_when_functions_have_same_structure_different_names() async {
    await assertAutoDiagnostics('''
void fetchUsers() {
  final response = 'data';
  if (response.isEmpty) {
    throw Exception('error');
  }
  print(response);
}

${expectLint(r'''void fetchOrders() {
  final result = 'data';
  if (result.isEmpty) {
    throw Exception('error');
  }
  print(result);
}''')}
''');
  }

  Future<void>
  test_does_not_report_when_functions_have_different_structure() async {
    await assertNoDiagnostics(r'''
void first() {
  final x = 1;
  if (x > 0) {
    print(x);
  }
  print('done');
}

void second() {
  final x = 1;
  while (x > 0) {
    print(x);
  }
  return;
}
''');
  }

  Future<void>
  test_does_not_report_when_body_below_min_statements() async {
    await assertNoDiagnostics(r'''
void first() {
  print('hello');
  print('world');
}

void second() {
  print('hello');
  print('world');
}
''');
  }

  Future<void>
  test_reports_on_methods_in_same_class() async {
    await assertAutoDiagnostics('''
class MyClass {
  void first() {
    final x = 1;
    if (x > 0) {
      print(x);
    }
    print('done');
  }

  ${expectLint(r'''void second() {
    final y = 1;
    if (y > 0) {
      print(y);
    }
    print('done');
  }''')}
}
''');
  }

  Future<void>
  test_reports_on_third_clone_also() async {
    await assertAutoDiagnostics('''
void first() {
  final x = 1;
  if (x > 0) {
    print(x);
  }
  print('done');
}

${expectLint(r'''void second() {
  final y = 1;
  if (y > 0) {
    print(y);
  }
  print('done');
}''')}

${expectLint(r'''void third() {
  final z = 1;
  if (z > 0) {
    print(z);
  }
  print('done');
}''')}
''');
  }

  // --- Ignore Literals Tests ---

  Future<void>
  test_reports_when_only_literal_values_differ() async {
    newAnalysisOptionsYamlFile(
      testPackageRootPath,
      '''${analysisOptionsContent(rules: [rule.name])}
plugins:
  solid_lints:
    diagnostics:
      avoid_duplicate_code:
        min_statements: 3
        ignore_literals: true
''',
    );
    await assertAutoDiagnostics('''
void first() {
  final x = 1;
  if (x > 0) {
    print('hello');
  }
  print('world');
}

${expectLint(r'''void second() {
  final y = 2;
  if (y > 0) {
    print('foo');
  }
  print('bar');
}''')}
''');
  }

  Future<void>
  test_does_not_report_when_literal_values_differ_without_flag() async {
    await assertNoDiagnostics(r'''
void first() {
  final x = 1;
  if (x > 0) {
    print('a');
  }
  print('b');
}

void second() {
  final y = 99;
  if (y > 0) {
    print('c');
  }
  print('d');
}
''');
  }

  // --- Ignore Identifiers Tests ---

  Future<void>
  test_does_not_report_when_identifiers_differ_without_flag() async {
    newAnalysisOptionsYamlFile(
      testPackageRootPath,
      '''${analysisOptionsContent(rules: [rule.name])}
plugins:
  solid_lints:
    diagnostics:
      avoid_duplicate_code:
        min_statements: 3
        ignore_identifiers: false
''',
    );
    await assertNoDiagnostics(r'''
void first() {
  final x = 1;
  if (x > 0) {
    print(x);
  }
  print('done');
}

void second() {
  final y = 1;
  if (y > 0) {
    print(y);
  }
  print('done');
}
''');
  }

  // --- Exclude Tests ---

  Future<void>
  test_does_not_report_on_excluded_function() async {
    await assertNoDiagnostics(r'''
void first() {
  final x = 1;
  if (x > 0) {
    print(x);
  }
  print('done');
}

void excluded() {
  final y = 1;
  if (y > 0) {
    print(y);
  }
  print('done');
}
''');
  }

  // --- Check Blocks Tests ---

  Future<void>
  test_reports_duplicate_blocks_inside_different_functions() async {
    await assertAutoDiagnostics('''
void one() {
  final x = 1;
  if (x > 0) {
    print('hello');
    print('world');
    print('done');
  }
}

void two() {
  final y = 2;
  ${expectLint(r'''{
    print('hello');
    print('world');
    print('done');
  }''')}
}
''');
  }

  Future<void>
  test_reports_parent_but_not_nested_blocks_when_parent_is_reported() async {
    await assertAutoDiagnostics('''
void one() {
  final x = 1;
  if (x > 0) {
    print('hello');
    print('world');
    print('done');
  }
  print('done');
}

${expectLint(r'''void two() {
  final y = 1;
  if (y > 0) {
    print('hello');
    print('world');
    print('done');
  }
  print('done');
}''')}
''');
  }
}
