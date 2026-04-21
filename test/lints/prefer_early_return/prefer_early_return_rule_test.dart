import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:solid_lints/src/lints/prefer_early_return/prefer_early_return_rule.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(PreferEarlyReturnRuleTest);
  });
}

@reflectiveTest
class PreferEarlyReturnRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = PreferEarlyReturnRule();
    super.setUp();
  }

  @override
  String get analysisRule => PreferEarlyReturnRule.lintName;

  void test_reports_if_as_only_statement_in_function() async {
    await assertDiagnostics(
      r'''
void test(bool a) {
  if (a) {
    print('hello');
  }
}
''',
      [lint(22, 32)],
    );
  }

  void test_reports_if_with_return() async {
    await assertDiagnostics(
      r'''
void test(bool a) {
  if (a) {
    print('hello');
  }

  return;
}
''',
      [lint(22, 32)],
    );
  }

  void test_does_not_report_if_with_return_value() async {
    await assertNoDiagnostics(
      r'''
int test(bool a) {
  if (a) {
    print('hello');
  }

  return 1;
}
''',
    );
  }

  void test_reports_nested_if_as_only_statement() async {
    await assertDiagnostics(
      r'''
void test(bool a, bool b) {
  if (a) {
    if (b) {
      print('nested');
    }
  }
}
''',
      [
        lint(30, 54),
      ],
    );
  }

  void test_does_not_report_nested_if_with_return_value() async {
    await assertNoDiagnostics(
      r'''
int test(bool a, bool b) {
  if (a) {
    if (b) {
      print('nested');
    }
  }

  return 1;
}
''',
    );
  }

  void test_reports_nested_3_if_as_only_statement() async {
    await assertDiagnostics(
      r'''
void test(bool a, bool b, bool c) {
  if (a) {
    if (b) {
      if (c){
        print('nested');
      }
    }
  }
}
''',
      [
        lint(38, 78),
      ],
    );
  }

  void test_reports_nested_3_with_return() async {
    await assertDiagnostics(
      r'''
void test(bool a, bool b, bool c) {
  if (a) {
    if (b) {
      if (c){
        print('nested');
      }
    }
  }
  return;
}
''',
      [
        lint(38, 78),
      ],
    );
  }

  void test_does_not_report_if_else() async {
    await assertNoDiagnostics(
      r'''
void test(bool a) {
  if (a) {
    print('hello');
  } else {
    print('hello');
  }
}
''',
    );
  }

  void test_does_not_report_if_else_return() async {
    await assertNoDiagnostics(
      r'''
void test(bool a) {
  if (a) {
    print('hello');
  } else {
    return;
  }
}
''',
    );
  }

  void test_does_not_report_nested_if_else() async {
    await assertNoDiagnostics(
      r'''
void test(bool a, bool b) {
  if (a) {
    if(b){
      print('hello');
    }
  } else {
    print('hello');
  }
}
''',
    );
  }

  void test_reports_inner_if_else() async {
    await assertDiagnostics(
      r'''
void test(bool a, bool b) {
  if (a) {
    if(b){
      print('hello');
    }
    else {
      print('hello');
    }
  } 
}
''',
      [
        lint(30, 90),
      ],
    );
  }

  void test_does_not_report_nested_3_with_else_1() async {
    await assertNoDiagnostics(
      r'''
void test(bool a, bool b, bool c) {
  if (a) {
    if (b) {
      if (c){
        print('nested');
      }
    }
  } else{
    print('hello');
  }
}
''',
    );
  }

  void test_reports_nested_3_with_else_2() async {
    await assertDiagnostics(
      r'''
void test(bool a, bool b, bool c) {
  if (a) {
    if (b) {
      if (c) {
        print('nested');
      }
    } else {
      print('nested');
    }
  }
}
''',
      [
        lint(38, 115),
      ],
    );
  }

  void test_reports_nested_3_with_else_3() async {
    await assertDiagnostics(
      r'''
void test(bool a, bool b, bool c) {
  if (a) {
    if (b) {
      if (c) {
        print('nested');
      }
      else {
        print('nested');
      }
    } 
  }
}
''',
      [
        lint(38, 126),
      ],
    );
  }

  void test_reports_2_sequencial_if() async {
    await assertDiagnostics(
      r'''
void test(bool a, bool b) {
  if (a) return;
  if (b) {
    print('gello');
  }
}
''',
      [
        lint(47, 32),
      ],
    );
  }

  void test_does_not_report_2_sequencial_if_with_return() async {
    await assertNoDiagnostics(
      r'''
void test(bool a, bool b) {
  if (a) return;
  if (b) return;

  return;
}
''',
    );
  }

  void test_reports_2_sequencial_if_with_return_2() async {
    await assertDiagnostics(
      r'''
void test(bool a, bool b) {
  if (a) return;
  if (b) {
    print('hello');
  }

  return;
}
''',
      [
        lint(47, 32),
      ],
    );
  }

  void test_does_not_report_2_sequencial_with_following_statement() async {
    await assertNoDiagnostics(
      r'''
void test(bool a, bool b) {
  if (a) return;
  if (b) {
    print('hello');
  }

  print('after');
}
''',
    );
  }

  void test_reports_2_sequencial_if_with_something() async {
    await assertDiagnostics(
      r'''
void test(bool a, bool b) {
  if (a) {
    print('hello');
  }
  if (b) {
    print('hello');
  }
}
''',
      [
        lint(65, 32),
      ],
    );
  }

  void test_reports_3_sequencial_if_with_return() async {
    await assertDiagnostics(
      r'''
void test(bool a, bool b, bool c) {
  if (a) return;
  if (b) return;
  if (c) {
    print('hello');
  }

  return;
}
''',
      [
        lint(72, 32),
      ],
    );
  }

  void test_reports_3_sequencial_if_with_something_2() async {
    await assertDiagnostics(
      r'''
void test(bool a, bool b, bool c) {
  if (a) return;
  if (b) {
    print('hello');
  }
  if (c) {
    print('hello');
  }
}
''',
      [
        lint(90, 32),
      ],
    );
  }

  void test_does_not_report_if_throw_with_return() async {
    await assertNoDiagnostics(
      r'''
void test(bool a) {
  if (a) {
    throw '';
  }

  return;
}
''',
    );
  }

  void test_does_not_report_if_else_throw() async {
    await assertNoDiagnostics(
      r'''
void test(bool a) {
  if (a) {
    print('hello');
  } else {
    throw '';
  }
}
''',
    );
  }

  void test_reports_2_sequencial_if_throw() async {
    await assertDiagnostics(
      r'''
void test(bool a, bool b) {
  if (a) throw '';
  if (b) {
    print('hello');
  }
}
''',
      [
        lint(49, 32),
      ],
    );
  }

  void test_reports_2_sequencial_if_throw_with_return() async {
    await assertDiagnostics(
      r'''
void test(bool a, bool b) {
  if (a) throw '';
  if (b) {
    print('hello');
  }

  return;
}
''',
      [
        lint(49, 32),
      ],
    );
  }

  void test_reports_3_sequencial_if_throw_with_return() async {
    await assertDiagnostics(
      r'''
void test(bool a, bool b, bool c) {
  if (a) throw '';
  if (b) throw '';
  if (c) {
    print('hello');
  }

  return;
}
''',
      [
        lint(76, 32),
      ],
    );
  }

  void test_reports_3_sequencial_if_throw_with_something() async {
    await assertDiagnostics(
      r'''
void test(bool a, bool b, bool c) {
  if (a) throw '';
  if (b) {
    print('hello');
  }
  if (c) {
    print('hello');
  }
}
''',
      [
        lint(92, 32),
      ],
    );
  }
}
