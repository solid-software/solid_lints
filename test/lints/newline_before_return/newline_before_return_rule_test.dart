import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:solid_lints/src/lints/newline_before_return/newline_before_return_rule.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../auto_test_lint_offsets.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(NewlineBeforeReturnRuleTest);
  });
}

@reflectiveTest
class NewlineBeforeReturnRuleTest extends AnalysisRuleTest
    with AutoTestLintOffsets {
  @override
  void setUp() {
    rule = NewlineBeforeReturnRule();
    super.setUp();
  }

  Future<void> test_reports_no_newline_before_return_value() async {
    await assertAutoDiagnostics('''
int method() {
  final a = 0;
  ${expectLint('return 1;')}
}
''');
  }

  Future<void> test_reports_no_newline_before_return() async {
    await assertAutoDiagnostics('''
void method() {
  final a = 0;
  ${expectLint('return;')}
}
''');
  }

  Future<void> test_reports_no_newline_before_return_with_comment() async {
    await assertAutoDiagnostics('''
void method() {
  final a = 0;
  // Comment
  ${expectLint('return;')}
}
''');
  }

  Future<void>
  test_reports_no_newline_before_return_with_multiple_comments() async {
    await assertAutoDiagnostics('''
void method() {
  final a = 0;
  // Comment 1
  // Comment 2
  ${expectLint('return;')}
}
''');
  }

  Future<void> test_does_not_report_newline_before_return_with_comment() async {
    await assertNoDiagnostics(r'''
void method() {
  final a = 0;
 
  // Comment
  return;
}
''');
  }

  Future<void>
  test_does_not_report_no_newline_before_single_statement_return() async {
    await assertNoDiagnostics(r'''
void method() {
  return;
}
''');
  }

  Future<void> test_does_not_report_newline_before_return() async {
    await assertNoDiagnostics(r'''
void method() {
  final a = 0;
  
  return;
}
''');
  }

  Future<void>
  test_does_not_report_no_newline_before_single_statement_return_value() async {
    await assertNoDiagnostics(r'''
int method() {
  return 1;
}
''');
  }

  Future<void>
  test_does_not_report_no_newline_before_single_statement_nested_return() async {
    await assertNoDiagnostics(r'''
class Foo {
  void bar(void Function()) {
    return;
  }
}

void fun() {
  final foo = Foo();
  foo.bar(() {
    return;
  });
}
''');
  }

  Future<void> test_reports_no_newline_before_return_nested() async {
    await assertAutoDiagnostics('''
class Foo {
  void bar(void Function()) {
    return;
  }
}

void fun() {
  final foo = Foo();
  foo.bar(() {
    final a = 1;
    ${expectLint('return;')}
  });
}
''');
  }

  Future<void> test_reports_no_newline_before_two_return_nested() async {
    await assertAutoDiagnostics('''
class Foo {
  void bar(void Function()) {
    return;
  }
}

void fun() {
  final foo = Foo();
  foo.bar(() {
    final a = 1;
    ${expectLint('return;')}
  });
  ${expectLint('return;')}
}
''');
  }
}
