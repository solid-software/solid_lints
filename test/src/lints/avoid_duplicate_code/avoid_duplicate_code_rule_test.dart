import 'package:analyzer/dart/analysis/utilities.dart' show parseString;
import 'package:analyzer/file_system/file_system.dart';
import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:analyzer_testing/utilities/utilities.dart';
import 'package:solid_lints/src/common/parameter_parser/analysis_options_loader.dart';
import 'package:solid_lints/src/common/parameters/excluded_identifier_parameter.dart';
import 'package:solid_lints/src/common/parameters/excluded_identifiers_list_parameter.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/avoid_duplicate_code_rule.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/models/avoid_duplicate_code_parameters.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/services/global_hash_registry.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/visitors/avoid_duplicate_code_visitor.dart';
import 'package:test/test.dart';
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
        check_blocks: true
        exclude:
          - method_name: excluded
  ''';

  @override
  void setUp() {
    GlobalHashRegistry.instance.clear();
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
    GlobalHashRegistry.instance.clear();
    await super.tearDown();
  }

  // --- Base Tests (min_tokens: 15, check_blocks: true, default) ---

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

  // --- Ignore Literals Tests ---

  Future<void> test_reports_when_only_literal_values_differ() async {
    newAnalysisOptionsYamlFile(
      testPackageRootPath,
      '''${analysisOptionsContent(rules: [rule.name])}
plugins:
  solid_lints:
    diagnostics:
      avoid_duplicate_code:
        min_tokens: 15
        ignore_literals: true
''',
    );
    await assertAutoDiagnostics('''
void first() ${expectLint(r'''{
  final x = 1;
  if (x > 0) {
    print('hello');
  }
  print('world');
}''')}

void second() ${expectLint(r'''{
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
        min_tokens: 15
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

    await _indexFile(otherFile);

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

  Future<void> test_ignores_nested_blocks_when_check_blocks_false() async {
    newAnalysisOptionsYamlFile(
      testPackageRootPath,
      '''${analysisOptionsContent(rules: [rule.name])}
plugins:
  solid_lints:
    diagnostics:
      avoid_duplicate_code:
        min_tokens: 15
        check_blocks: false
''',
    );

    // The nested blocks are identical (>15 tokens), but check_blocks is false,
    // and the outer function bodies differ significantly.
    await assertNoDiagnostics(r'''
void one() {
  final x = 1;
  if (x > 0) {
    print('hello');
    print('world');
    print('done');
  }
}

void two() {
  print('completely different start');
  if (true) {
    print('hello');
    print('world');
    print('done');
  }
}
''');
  }

  Future<void>
  test_does_not_report_when_identifiers_are_different_method_calls() async {
    // Tests that ignore_identifiers=true still differentiates method calls.
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

  Future<void>
  test_duplicate_code_with_three_files_and_excluded_part_file() async {
    newAnalysisOptionsYamlFile(testPackageRootPath, '''
linter:
  rules:
    - ${rule.name}
analyzer:
  exclude:
    - "**/*.g.dart"
$_mockAnalysisOptionsContent
''');
    rule = AvoidDuplicateCodeRule(
      analysisOptionsLoader: AnalysisOptionsLoader(
        resourceProvider: resourceProvider,
      ),
    );

    // 1. First file: other.dart (separate file with identical code)
    final otherFile = newFile('$testPackageLibPath/other.dart', '''
void otherMethod() {
  final x = 1;
  if (x > 0) {
    print(x);
  }
  print('done');
}
''');

    // 2. Second file: part.g.dart (part file with identical code)
    newFile('$testPackageLibPath/part.g.dart', '''
part of 'test.dart';

void partMethod() {
  final x = 1;
  if (x > 0) {
    print(x);
  }
  print('done');
}
''');

    // Populate registry with other.dart
    await _indexFile(otherFile);

    // 3. Third file: test.dart (main library, not excluded)
    // Expect: mainMethod in test.dart is flagged as duplicate of other.dart.
    // part.g.dart will NOT trigger diagnostics because .g.dart is excluded.
    await assertAutoDiagnostics('''
part 'part.g.dart';

void mainMethod() ${expectLint(r'''{
  final x = 1;
  if (x > 0) {
    print(x);
  }
  print('done');
}''')}
''');
  }

  Future<void>
  test_ignored_method_with_comment_does_not_trigger_cross_file_duplicates() async {
    // 1. Create other.dart where the method is marked with ignore comment
    final otherFile = newFile('$testPackageLibPath/other.dart', '''
// ignore: solid_lints/avoid_duplicate_code
void ignoredMethod() {
  final x = 1;
  if (x > 0) {
    print(x);
  }
  print('done');
}
''');

    // Populate registry with other.dart
    await _indexFile(otherFile);

    // 2. test.dart has identical code, but other.dart's method was ignored.
    // Therefore, test.dart should have NO duplicates reported!
    await assertNoDiagnostics('''
void mainMethod() {
  final x = 1;
  if (x > 0) {
    print(x);
  }
  print('done');
}
''');
  }

  Future<void>
  test_ignored_file_with_ignore_for_file_does_not_trigger_cross_file_duplicates() async {
    // 1. Create other.dart with ignore_for_file comment
    final otherFile = newFile('$testPackageLibPath/other.dart', '''
// ignore_for_file: avoid_duplicate_code

void otherMethod() {
  final x = 1;
  if (x > 0) {
    print(x);
  }
  print('done');
}
''');

    // Populate registry with other.dart
    await _indexFile(otherFile);

    // 2. test.dart has identical code, but other.dart was ignored for file.
    // Therefore, test.dart should have NO duplicates reported!
    await assertNoDiagnostics('''
void mainMethod() {
  final x = 1;
  if (x > 0) {
    print(x);
  }
  print('done');
}
''');
  }

  Future<void> test_visiting_ignored_file_removes_it_from_registry() async {
    final otherFile = newFile('$testPackageLibPath/other.dart', '''
void otherMethod() {
  final x = 1;
  if (x > 0) {
    print(x);
  }
  print('done');
}
''');
    await _indexFile(otherFile);
    expect(GlobalHashRegistry.instance.fileCount, 1);

    final result = parseString(
      content: '''
// ignore_for_file: avoid_duplicate_code
void otherMethod() {
  final x = 1;
  if (x > 0) {
    print(x);
  }
  print('done');
}
''',
    );
    final avoidRule = rule as AvoidDuplicateCodeRule;
    final visitor = AvoidDuplicateCodeVisitor(
      avoidRule,
      AvoidDuplicateCodeParameters.empty(),
      filePath: otherFile.path,
      modificationStamp: 2,
      ignoreMatcher: avoidRule.ignoreMatcher,
      resourceProvider: resourceProvider,
      analysisOptionsLoader: avoidRule.analysisOptionsLoader,
    );
    result.unit.accept(visitor);

    expect(GlobalHashRegistry.instance.fileCount, 0);
  }

  Future<void> _indexFile(
    File file, {
    AvoidDuplicateCodeParameters? parameters,
  }) async {
    final resolved = await resolveFile(file.path);
    final avoidRule = rule as AvoidDuplicateCodeRule;
    final visitor = AvoidDuplicateCodeVisitor(
      avoidRule,
      parameters ??
          AvoidDuplicateCodeParameters(
            minTokens: 15,
            ignoreLiterals: false,
            ignoreIdentifiers: true,
            checkBlocks: true,
            exclude: ExcludedIdentifiersListParameter(
              exclude: [ExcludedIdentifierParameter(methodName: 'excluded')],
            ),
          ),
      filePath: file.path,
      modificationStamp: 1,
      ignoreMatcher: avoidRule.ignoreMatcher,
      contextRoot: resolved.session.analysisContext.contextRoot,
      resourceProvider: resourceProvider,
      analysisOptionsLoader: avoidRule.analysisOptionsLoader,
    );
    resolved.unit.accept(visitor);
  }
}
