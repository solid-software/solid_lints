import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:solid_lints/src/lints/prefer_early_return/prefer_early_return_rule.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../auto_test_lint_offsets.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(PreferEarlyReturnRuleTest);
  });
}

@reflectiveTest
class PreferEarlyReturnRuleTest extends AnalysisRuleTest
    with AutoTestLintOffsets {
  @override
  void setUp() {
    rule = PreferEarlyReturnRule();
    super.setUp();
  }

  Future<void> test_reports_if_as_only_statement_in_function() async {
    await assertAutoDiagnostics('''
void test(bool a) {
  ${expectLint('''if (a) {
    print('hello');
  }''')}
}
''');
  }

  Future<void> test_reports_if_with_return() async {
    await assertAutoDiagnostics('''
void test(bool a) {
  ${expectLint('''if (a) {
    print('hello');
  }''')}

  return;
}
''');
  }

  Future<void> test_does_not_report_if_with_return_value() async {
    await assertNoDiagnostics(r'''
int test(bool a) {
  if (a) {
    print('hello');
  }

  return 1;
}
''');
  }

  Future<void> test_reports_nested_if_as_only_statement() async {
    await assertAutoDiagnostics('''
void test(bool a, bool b) {
  ${expectLint('''if (a) {
    if (b) {
      print('nested');
    }
  }''')}
}
''');
  }

  Future<void> test_does_not_report_nested_if_with_return_value() async {
    await assertNoDiagnostics(r'''
int test(bool a, bool b) {
  if (a) {
    if (b) {
      print('nested');
    }
  }

  return 1;
}
''');
  }

  Future<void> test_reports_nested_3_if_as_only_statement() async {
    await assertAutoDiagnostics('''
void test(bool a, bool b, bool c) {
  ${expectLint('''if (a) {
    if (b) {
      if (c){
        print('nested');
      }
    }
  }''')}
}
''');
  }

  Future<void> test_reports_nested_3_with_return() async {
    await assertAutoDiagnostics('''
void test(bool a, bool b, bool c) {
  ${expectLint('''if (a) {
    if (b) {
      if (c){
        print('nested');
      }
    }
  }''')}
  return;
}
''');
  }

  Future<void> test_does_not_report_if_else() async {
    await assertNoDiagnostics(r'''
void test(bool a) {
  if (a) {
    print('hello');
  } else {
    print('hello');
  }
}
''');
  }

  Future<void> test_does_not_report_if_else_return() async {
    await assertNoDiagnostics(r'''
void test(bool a) {
  if (a) {
    print('hello');
  } else {
    return;
  }
}
''');
  }

  Future<void> test_does_not_report_nested_if_else() async {
    await assertNoDiagnostics(r'''
void test(bool a, bool b) {
  if (a) {
    if(b){
      print('hello');
    }
  } else {
    print('hello');
  }
}
''');
  }

  Future<void> test_reports_inner_if_else() async {
    await assertAutoDiagnostics('''
void test(bool a, bool b) {
  ${expectLint('''if (a) {
    if(b){
      print('hello');
    }
    else {
      print('hello');
    }
  }''')} 
}
''');
  }

  Future<void> test_reports_on_three_if() async {
    await assertAutoDiagnostics('''
void threeIf(bool a, bool b, bool c) {
  ${expectLint('''if (a) {
    if (b) {
      if (c) {
        print('hello');
      }
    }
  }''')}
}''');
  }

  Future<void> test_does_not_report_nested_3_with_else_1() async {
    await assertNoDiagnostics(r'''
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
''');
  }

  Future<void> test_reports_nested_3_with_else_2() async {
    await assertAutoDiagnostics('''
void test(bool a, bool b, bool c) {
  ${expectLint('''if (a) {
    if (b) {
      if (c) {
        print('nested');
      }
    } else {
      print('nested');
    }
  }''')}
}
''');
  }

  Future<void> test_reports_nested_3_with_else_3() async {
    await assertAutoDiagnostics('''
void test(bool a, bool b, bool c) {
  ${expectLint('''if (a) {
    if (b) {
      if (c) {
        print('nested');
      }
      else {
        print('nested');
      }
    } 
  }''')}
}
''');
  }

  Future<void> test_reports_2_sequencial_if() async {
    await assertAutoDiagnostics('''
void test(bool a, bool b) {
  if (a) return;
  ${expectLint('''if (b) {
    print('gello');
  }''')}
}
''');
  }

  Future<void> test_does_not_report_2_sequencial_if_with_return() async {
    await assertNoDiagnostics(r'''
void test(bool a, bool b) {
  if (a) return;
  if (b) return;

  return;
}
''');
  }

  Future<void> test_reports_2_sequencial_if_with_return_2() async {
    await assertAutoDiagnostics('''
void test(bool a, bool b) {
  if (a) return;
  ${expectLint('''if (b) {
    print('hello');
  }''')}

  return;
}
''');
  }

  Future<void>
  test_does_not_report_2_sequencial_with_following_statement() async {
    await assertNoDiagnostics(r'''
void test(bool a, bool b) {
  if (a) return;
  if (b) {
    print('hello');
  }

  print('after');
}
''');
  }

  Future<void> test_reports_2_sequencial_if_with_something() async {
    await assertAutoDiagnostics('''
void test(bool a, bool b) {
  if (a) {
    print('hello');
  }
  ${expectLint('''if (b) {
    print('hello');
  }''')}
}
''');
  }

  Future<void> test_reports_3_sequencial_if_with_return() async {
    await assertAutoDiagnostics('''
void test(bool a, bool b, bool c) {
  if (a) return;
  if (b) return;
  ${expectLint('''if (c) {
    print('hello');
  }''')}

  return;
}
''');
  }

  Future<void> test_reports_3_sequencial_if_with_something_2() async {
    await assertAutoDiagnostics('''
void test(bool a, bool b, bool c) {
  if (a) return;
  if (b) {
    print('hello');
  }
  ${expectLint('''if (c) {
    print('hello');
  }''')}
}
''');
  }

  Future<void> test_does_not_report_if_throw_with_return() async {
    await assertNoDiagnostics(r'''
void test(bool a) {
  if (a) {
    throw '';
  }

  return;
}
''');
  }

  Future<void> test_does_not_report_if_else_throw() async {
    await assertNoDiagnostics(r'''
void test(bool a) {
  if (a) {
    print('hello');
  } else {
    throw '';
  }
}
''');
  }

  Future<void> test_reports_2_sequencial_if_throw() async {
    await assertAutoDiagnostics('''
void test(bool a, bool b) {
  if (a) throw '';
  ${expectLint('''if (b) {
    print('hello');
  }''')}
}
''');
  }

  Future<void> test_reports_2_sequencial_if_throw_with_return() async {
    await assertAutoDiagnostics('''
void test(bool a, bool b) {
  if (a) throw '';
  ${expectLint('''if (b) {
    print('hello');
  }''')}

  return;
}
''');
  }

  Future<void> test_reports_3_sequencial_if_throw_with_return() async {
    await assertAutoDiagnostics('''
void test(bool a, bool b, bool c) {
  if (a) throw '';
  if (b) throw '';
  ${expectLint('''if (c) {
    print('hello');
  }''')}

  return;
}
''');
  }

  Future<void> test_reports_3_sequencial_if_throw_with_something() async {
    await assertAutoDiagnostics('''
void test(bool a, bool b, bool c) {
  if (a) throw '';
  if (b) {
    print('hello');
  }
  ${expectLint('''if (c) {
    print('hello');
  }''')}
}
''');
  }
}
