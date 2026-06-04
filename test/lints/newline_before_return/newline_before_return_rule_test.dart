import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:solid_lints/src/lints/newline_before_return/newline_before_return_rule.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(NewlineBeforeReturnRuleTest);
  });
}

@reflectiveTest
class NewlineBeforeReturnRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = NewlineBeforeReturnRule();
    super.setUp();
  }

  @override
  String get analysisRule => rule.name;

  void test_reports_no_newline_before_return_value() async {
    await assertDiagnostics(
      r'''
int method() {
  final a = 0;
  return 1;
}
  ''',
      [lint(32, 9)],
    );
  }

  void test_reports_no_newline_before_return() async {
    await assertDiagnostics(
      r'''
void method() {
  final a = 0;
  return;
}
  ''',
      [lint(33, 7)],
    );
  }

  void test_reports_no_newline_before_return_with_comment() async {
    await assertDiagnostics(
      r'''
void method() {
  final a = 0;
  // Comment
  return;
}
  ''',
      [lint(46, 7)],
    );
  }

  void test_does_not_report_no_newline_before_single_statement_return() async {
    await assertNoDiagnostics(r'''
void method() {
  return;
}
  ''');
  }

  void test_does_not_report_newline_before_return() async {
    await assertNoDiagnostics(r'''
void method() {
  final a = 0;
  
  return;
}
  ''');
  }

  void
  test_does_not_report_no_newline_before_single_statement_return_value() async {
    await assertNoDiagnostics(r'''
int method() {
  return 1;
}
  ''');
  }

  void
  test_does_not_report_no_newline_before_single_statement_nested_return() async {
    await assertNoDiagnostics(r'''
class Foo{
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

  void test_reports_no_newline_before_return_nested() async {
    await assertDiagnostics(
      r'''
class Foo{
  void bar(void Function()) {
    return;
  }
}

void fun() {
  final foo = Foo();
  foo.bar(() {
    final a = 1;
    return;
  });
}
  ''',
      [lint(130, 7)],
    );
  }

  void test_reports_no_newline_before_two_return_nested() async {
    await assertDiagnostics(
      r'''
class Foo{
  void bar(void Function()) {
    return;
  }
}

void fun() {
  final foo = Foo();
  foo.bar(() {
    final a = 1;
    return;
  });
  return;
}
  ''',
      [lint(130, 7), lint(146, 7)],
    );
  }
}
