import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:analyzer_testing/utilities/utilities.dart';
import 'package:solid_lints/src/common/parameter_parser/analysis_options_loader.dart';
import 'package:solid_lints/src/lints/no_empty_block/no_empty_block_rule.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../../../lints/auto_test_lint_offsets.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(NoEmptyBlockRuleTest);
  });
}

@reflectiveTest
class NoEmptyBlockRuleTest extends AnalysisRuleTest with AutoTestLintOffsets {
  @override
  void setUp() {
    rule = NoEmptyBlockRule(
      analysisOptionsLoader: AnalysisOptionsLoader(
        resourceProvider: resourceProvider,
      ),
    );
    super.setUp();
  }

  @override
  String get analysisRule => NoEmptyBlockRule.lintName;

  Future<void> test_reports_on_empty_function() async {
    await assertAutoDiagnostics('''
void fun() ${expectLint('{}')}
''');
  }

  Future<void> test_reports_on_empty_if_block() async {
    await assertAutoDiagnostics('''
void fun() {
  if (true) ${expectLint('{}')}
}
''');
  }

  Future<void> test_does_not_report_on_catch_clause() async {
    await assertNoDiagnostics(r'''
void fun() {
  try {
    print('hello');
  } catch (e) {}
}
''');
  }

  Future<void> test_does_not_report_on_todo_comment() async {
    await assertNoDiagnostics(r'''
// ignore_for_file: todo
void fun() {
  // TODO: implement
}
''');
  }

  Future<void> test_does_not_report_on_any_comment_if_allowed() async {
    newAnalysisOptionsYamlFile(
      testPackageRootPath,
      '''${analysisOptionsContent(rules: [rule.name])}
plugins:
  solid_lints:
    diagnostics:
      no_empty_block:
        allow_with_comments: true
''',
    );

    await assertNoDiagnostics(r'''
void fun() {
  // some explanation comment
}
''');
  }

  Future<void> test_does_not_report_on_excluded() async {
    newAnalysisOptionsYamlFile(
      testPackageRootPath,
      '''${analysisOptionsContent(rules: [rule.name])}
plugins:
  solid_lints:
    diagnostics:
      no_empty_block:
        exclude:
          - method_name: excludeMethod
          - class_name: Exclude
            method_name: excludeMethod
''',
    );

    await assertNoDiagnostics(r'''
void excludeMethod() {}

class Exclude {
  void excludeMethod() {}
}
''');
  }

  Future<void> test_reports_on_empty_try_block() async {
    await assertAutoDiagnostics('''
void fun() {
  try ${expectLint('{}')} catch (e) {}
}
''');
  }

  Future<void> test_reports_on_empty_closure() async {
    await assertAutoDiagnostics('''
void nestedFun(void Function() fun) {
  print('not empty');
}

void doStuff() {
  nestedFun(() ${expectLint('{}')});
}
''');
  }

  Future<void> test_reports_on_empty_class_method() async {
    await assertAutoDiagnostics('''
class A {
  void method() ${expectLint('{}')}
}
''');
  }

  Future<void> test_does_not_report_on_class_method_with_todo() async {
    await assertNoDiagnostics(r'''
// ignore_for_file: todo
class A {
  void toDoMethod() {
    // TODO: implement toDoMethod
  }
}
''');
  }

  Future<void> test_reports_on_empty_finally_block() async {
    await assertAutoDiagnostics('''
void fun() {
  try {
    print('try');
  } finally ${expectLint('{}')}
}
''');
  }

  Future<void> test_reports_on_empty_constructor_body() async {
    await assertAutoDiagnostics('''
class A {
  A() ${expectLint('{}')}
}
''');
  }

  Future<void> test_reports_on_empty_for_loop_block() async {
    await assertAutoDiagnostics('''
void fun() {
  for (var i = 0; i < 10; i++) ${expectLint('{}')}
}
''');
  }

  Future<void> test_reports_on_empty_while_loop_block() async {
    await assertAutoDiagnostics('''
void fun() {
  while (true) ${expectLint('{}')}
}
''');
  }

  Future<void> test_reports_on_empty_else_block() async {
    await assertAutoDiagnostics('''
void fun(bool condition) {
  if (condition) {
    print('if');
  } else ${expectLint('{}')}
}
''');
  }
}
