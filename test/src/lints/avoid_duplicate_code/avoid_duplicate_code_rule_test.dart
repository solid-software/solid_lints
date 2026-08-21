import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:analyzer_testing/utilities/utilities.dart';
import 'package:solid_lints/src/common/parameter_parser/analysis_options_loader.dart';
import 'package:solid_lints/src/common/parameters/excluded_identifier_parameter.dart';
import 'package:solid_lints/src/common/parameters/excluded_identifiers_list_parameter.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/avoid_duplicate_code_rule.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/models/avoid_duplicate_code_parameters.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/services/global_hash_registry.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/visitors/avoid_duplicate_code_visitor.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../../utils/auto_test_lint_offsets.dart';

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
        min_tokens: 15
        exclude:
          - method_name: excluded
  ''';

  @override
  void setUp() {
    GlobalHashRegistry.instance.clear(resourceProvider: resourceProvider);
    GlobalHashRegistry.instance.enablePhysicalFileCleanup = false;
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

  @override
  Future<void> tearDown() async {
    GlobalHashRegistry.instance.clear(resourceProvider: resourceProvider);
    await super.tearDown();
  }

  // --- Base Tests (min_tokens: 15, default) ---

  Future<void> test_reports_when_two_functions_have_identical_bodies() async {
    await assertAutoDiagnostics('''
void first() ${expectLint(r'''{
  final x = 1;
  if (x > 0) {
    print(x);
  }
  print('done');
}''')}

void second() ${expectLint(r'''{
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
void fetchUsers() ${expectLint(r'''{
  final response = 'data';
  if (response.isEmpty) {
    throw Exception('error');
  }
  print(response);
}''')}

void fetchOrders() ${expectLint(r'''{
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

  Future<void> test_does_not_report_when_body_below_min_tokens() async {
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

  Future<void> test_reports_on_methods_in_same_class() async {
    await assertAutoDiagnostics('''
class MyClass {
  void first() ${expectLint(r'''{
    final x = 1;
    if (x > 0) {
      print(x);
    }
    print('done');
  }''')}

  void second() ${expectLint(r'''{
    final y = 1;
    if (y > 0) {
      print(y);
    }
    print('done');
  }''')}
}
''');
  }

  Future<void> test_reports_on_third_clone_also() async {
    await assertAutoDiagnostics('''
void first() ${expectLint(r'''{
  final x = 1;
  if (x > 0) {
    print(x);
  }
  print('done');
}''')}

void second() ${expectLint(r'''{
  final y = 1;
  if (y > 0) {
    print(y);
  }
  print('done');
}''')}

void third() ${expectLint(r'''{
  final z = 1;
  if (z > 0) {
    print(z);
  }
  print('done');
}''')}
''');
  }

  // --- Literals Tests ---

  Future<void> test_reports_when_only_literal_values_differ() async {
    await assertAutoDiagnostics('''
void first() ${expectLint(r'''{
  final x = 1;
  if (x > 0) {
    print('hello');
  }
  print('world');
}''', messageContainsAll: ['differs in literal values', '[1, 2]', "['hello', 'foo']", "['world', 'bar']"])}

void second() ${expectLint(r'''{
  final y = 2;
  if (y > 0) {
    print('foo');
  }
  print('bar');
}''', messageContainsAll: ['differs in literal values', '[2, 1]', "['foo', 'hello']", "['bar', 'world']"])}
''');
  }

  Future<void> test_reports_differing_literals_across_three_clones() async {
    await assertAutoDiagnostics('''
void first() ${expectLint(r'''{
  final x = 1;
  if (x > 0) {
    print('hello');
  }
  print('world');
}''', messageContainsAll: ['differs in literal values', '[1, 2, 3]', "['hello', 'foo', 'baz']", "['world', 'bar', 'qux']"])}

void second() ${expectLint(r'''{
  final y = 2;
  if (y > 0) {
    print('foo');
  }
  print('bar');
}''', messageContainsAll: ['differs in literal values', '[2, 1, 3]', "['foo', 'hello', 'baz']", "['bar', 'world', 'qux']"])}

void third() ${expectLint(r'''{
  final z = 3;
  if (z > 0) {
    print('baz');
  }
  print('qux');
}''', messageContainsAll: ['differs in literal values', '[3, 1, 2]', "['baz', 'hello', 'foo']", "['qux', 'world', 'bar']"])}
''');
  }

  Future<void>
  test_reports_exact_and_different_literals_in_mixed_scenario() async {
    await assertAutoDiagnostics('''
void first() ${expectLint(r'''{
  final x = 1;
  if (x > 0) {
    print('hello');
  }
  print('world');
}''', messageContainsAll: ['Perhaps this code is a duplicate'])}

void second() ${expectLint(r'''{
  final y = 1;
  if (y > 0) {
    print('hello');
  }
  print('world');
}''', messageContainsAll: ['Perhaps this code is a duplicate'])}

void third() ${expectLint(r'''{
  final z = 2;
  if (z > 0) {
    print('foo');
  }
  print('bar');
}''', messageContainsAll: ['differs in literal values'])}
''');
  }

  Future<void>
  test_reports_differing_literals_truncates_slots_when_more_than_limit() async {
    await assertAutoDiagnostics('''
void first() ${expectLint(r'''{
  final a = 1;
  final b = 10;
  if (a > 0) {
    print('hello');
  }
  print('world');
}''', messageContainsAll: ['differs in literal values', '[1, 2]', '[10, 20]', "['hello', 'foo']", '(+1 more)'])}

void second() ${expectLint(r'''{
  final a = 2;
  final b = 20;
  if (a > 0) {
    print('foo');
  }
  print('bar');
}''', messageContainsAll: ['differs in literal values', '[2, 1]', '[20, 10]', "['foo', 'hello']", '(+1 more)'])}
''');
  }

  Future<void>
  test_reports_differing_literals_truncates_values_when_more_than_limit() async {
    await assertAutoDiagnostics('''
void first() ${expectLint(r'''{
  final x = 1;
  if (x > 0) {
    print('hello');
  }
  print('world');
}''', messageContainsAll: ['differs in literal values', '[1, 2, 3, +1 more]'])}

void second() ${expectLint(r'''{
  final y = 2;
  if (y > 0) {
    print('foo');
  }
  print('bar');
}''', messageContainsAll: ['differs in literal values', '[2, 1, 3, +1 more]'])}

void third() ${expectLint(r'''{
  final z = 3;
  if (z > 0) {
    print('baz');
  }
  print('qux');
}''', messageContainsAll: ['differs in literal values', '[3, 1, 2, +1 more]'])}

void fourth() ${expectLint(r'''{
  final w = 4;
  if (w > 0) {
    print('quux');
  }
  print('corge');
}''', messageContainsAll: ['differs in literal values', '[4, 1, 2, +1 more]'])}
''');
  }

  // --- Exclude Tests ---

  Future<void> test_does_not_report_on_excluded_function() async {
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
  if (x > 0) ${expectLint(r'''{
    print('hello');
    print('world');
    print('done');
  }''')}
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
void one() ${expectLint(r'''{
  final x = 1;
  if (x > 0) {
    print('hello');
    print('world');
    print('done');
  }
  print('done');
}''')}

void two() ${expectLint(r'''{
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

  Future<void> test_reports_cross_file_duplicate_when_in_registry() async {
    final otherFile = newFile('$testPackageLibPath/other.dart', '''
void otherMethod() {
  final x = 1;
  if (x > 0) {
    print(x);
  }
  print('done');
}
''');

    final resolvedOther = await resolveFile(otherFile.path);
    final visitor = AvoidDuplicateCodeVisitor(
      rule as AvoidDuplicateCodeRule,
      AvoidDuplicateCodeParameters(
        minTokens: 15,
        exclude: ExcludedIdentifiersListParameter(
          exclude: [ExcludedIdentifierParameter(methodName: 'excluded')],
        ),
      ),
      filePath: otherFile.path,
      modificationStamp: 1,
      contextRoot: resolvedOther.session.analysisContext.contextRoot,
      resourceProvider: resourceProvider,
    );
    resolvedOther.unit.accept(visitor);

    await assertAutoDiagnostics('''
void mainMethod() ${expectLint(r'''{
  final x = 1;
  if (x > 0) {
    print(x);
  }
  print('done');
}''')}
''');
  }

  Future<void> test_reports_on_expression_function_bodies() async {
    // 15+ tokens are needed. We repeat a pattern to ensure token count.
    await assertAutoDiagnostics('''
int first(int a, int b) ${expectLint(r'''=> a + b + a + b + 
  a + b + a + b + a + b + a + b;''')}

int second(int x, int y) ${expectLint(r'''=> x + y + x + y + 
  x + y + x + y + x + y + x + y;''')}
''');
  }

  Future<void> test_reports_despite_different_comments_and_formatting() async {
    await assertAutoDiagnostics('''
void first() ${expectLint(r'''{
  final x = 1;
  // This is a comment
  if (x > 0) {
    print(x);
  }
  print('done');
}''')}

void second() ${expectLint(r'''{
  final y = 1;


  if (y > 0) {
    /* multiline
       comment */
    print(y);
  }
  
  print('done');
}''')}
''');
  }

  Future<void>
  test_reports_cross_file_duplicate_when_literals_differ_in_registry() async {
    final otherFile = newFile('$testPackageLibPath/other.dart', '''
void otherMethod() {
  final x = 1;
  if (x > 0) {
    print('hello');
  }
  print('world');
}
''');

    final resolvedOther = await resolveFile(otherFile.path);
    final visitor = AvoidDuplicateCodeVisitor(
      rule as AvoidDuplicateCodeRule,
      AvoidDuplicateCodeParameters(
        minTokens: 15,
        exclude: ExcludedIdentifiersListParameter(
          exclude: [ExcludedIdentifierParameter(methodName: 'excluded')],
        ),
      ),
      filePath: otherFile.path,
      modificationStamp: 1,
      contextRoot: resolvedOther.session.analysisContext.contextRoot,
      resourceProvider: resourceProvider,
    );
    resolvedOther.unit.accept(visitor);

    await assertAutoDiagnostics('''
void mainMethod() ${expectLint(r'''{
  final y = 2;
  if (y > 0) {
    print('foo');
  }
  print('bar');
}''', messageContainsAll: ['differs in literal values', '[2, 1]', "['foo', 'hello']", "['bar', 'world']"])}
''');
  }

  Future<void>
  test_does_not_report_when_identifiers_are_different_method_calls() async {
    // Tests that different method calls are differentiated.
    // Local variables are ignored, but external method names are preserved.
    await assertNoDiagnostics('''
void doSomething(int x) {}
void doAnotherThing(int x) {}

void first() {
  final x = 1;
  if (x > 0) {
    doSomething(x);
  }
  print('done');
}

void second() {
  final y = 1;
  if (y > 0) {
    doAnotherThing(y);
  }
  print('done');
}
''');
  }

  Future<void> test_reports_when_only_symbol_literals_differ() async {
    await assertAutoDiagnostics('''
void first() ${expectLint(r'''{
  final action = #foo;
  if (action == #foo) {
    print('hello');
  }
  print('done');
}''', messageContainsAll: ['differs in literal values', '[#foo, #bar]'])}

void second() ${expectLint(r'''{
  final action = #bar;
  if (action == #bar) {
    print('hello');
  }
  print('done');
}''', messageContainsAll: ['differs in literal values', '[#bar, #foo]'])}
''');
  }

  Future<void>
  test_reports_exact_duplicate_when_symbol_literals_are_identical() async {
    await assertAutoDiagnostics('''
void first() ${expectLint(r'''{
  final action = #foo;
  if (action == #foo) {
    print('hello');
  }
  print('done');
}''', messageContainsAll: ['Perhaps this code is a duplicate'])}

void second() ${expectLint(r'''{
  final action = #foo;
  if (action == #foo) {
    print('hello');
  }
  print('done');
}''', messageContainsAll: ['Perhaps this code is a duplicate'])}
''');
  }

  Future<void> test_does_not_report_when_named_argument_labels_differ() async {
    await assertNoDiagnostics('''
void callMe({int? width, int? height, int? count}) {}

void first() {
  final x = 1;
  callMe(width: x, count: 10);
  print('done');
}

void second() {
  final y = 1;
  callMe(height: y, count: 10);
  print('done');
}
''');
  }

  Future<void> test_reports_when_numeric_literal_signs_differ() async {
    await assertAutoDiagnostics('''
void moveLeft() ${expectLint(r'''{
  final dx = -10;
  if (dx < 0) {
    print('moving');
  }
  print('done');
}''', messageContainsAll: ['differs in literal values', '[-10, 10]'])}

void moveRight() ${expectLint(r'''{
  final dx = 10;
  if (dx < 0) {
    print('moving');
  }
  print('done');
}''', messageContainsAll: ['differs in literal values', '[10, -10]'])}
''');
  }
}
