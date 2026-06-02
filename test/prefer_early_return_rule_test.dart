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

  Future<void> test_reports_on_one_if() async {
    await assertDiagnostics(
      r'''
void oneIf(bool a) {
  if (a) {
    print('s');
  }
}''',
      [lint(23, 28)],
    );
  }

  Future<void> test_doesn_not_report_on_one_if_with_return_value() async {
    await assertNoDiagnostics(r'''
int oneIfWithReturnValue(bool a) {
  if (a) {
    print('s');
  }

  return 1;
}''');
  }

  Future<void> test_reports_on_one_if_with_return() async {
    await assertDiagnostics(
      r'''
void oneIfWithReturn(bool a) {
  if (a) {
    print('s');
  }

  return;
}''',
      [lint(33, 28)],
    );
  }

  Future<void> test_reports_on_nested_if2() async {
    await assertDiagnostics(
      r'''
void nestedIf2(bool a, bool b) {
  if (a) {
    if (b) {
      print('s');
    }
  }
}''',
      [lint(35, 49)],
    );
  }

  Future<void> test_doesn_not_report_on_nested_if2_with_return_value() async {
    await assertNoDiagnostics(
      r'''
int nestedIf2WithReturnValue(bool a, bool b) {
  if (a) {
    if (b) {
      print('s');
    }
  }

  return 1;
}''',
    );
  }

  Future<void> test_reports_on_nested_if3() async {
    await assertDiagnostics(
      r'''
void nestedIf3(bool a, bool b, bool c) {
  if (a) {
    if (b) {
      if (c) {
        print('s');
      }
    }
  }
}''',
      [lint(43, 74)],
    );
  }

  Future<void> test_reports_on_one_nested_if2_with_return() async {
    await assertDiagnostics(
      r'''
void oneNestedIf2WithReturn(bool a, bool b, bool c) {
  if (a) {
    if (b) {
      if (c) {
        print('s');
      }
    }
  }

  return;
}''',
      [lint(56, 74)],
    );
  }

  Future<void> test_doesn_not_report_on_one_if_else() async {
    await assertNoDiagnostics(r'''
void oneIfElse(bool a) {
  if (a) {
    print('s');
  } else {
    print('s');
  }
}''');
  }

  Future<void> test_doesn_not_report_on_one_if_else_return() async {
    await assertNoDiagnostics(r'''
void oneIfElseReturn(bool a) {
  if (a) {
    print('s');
  } else {
    return;
  }
}''');
  }

  Future<void> test_doesn_not_report_on_two_if_else() async {
    await assertNoDiagnostics(r'''
void twoIfElse(bool a, bool b) {
  if (a) {
    if (b) {
      print('s');
    }
  } else {
    print('s');
  }
}''');
  }

  Future<void> test_reports_on_two_if_else_inner() async {
    await assertDiagnostics(
      r'''
void twoIfElseInner(bool a, bool b) {
  if (a) {
    if (b) {
      print('s');
    } else {
      print('s');
    }
  }
}''',
      [lint(40, 80)],
    );
  }

  Future<void> test_reports_on_three_if() async {
    await assertDiagnostics(
      r'''
void threeIf(bool a, bool b, bool c) {
  if (a) {
    if (b) {
      if (c) {
        print('s');
      }
    }
  }
}''',
      [lint(41, 74)],
    );
  }

  Future<void> test_doesn_not_report_on_three_if_else1() async {
    await assertNoDiagnostics(r'''
void threeIfElse1(bool a, bool b, bool c) {
  if (a) {
    if (b) {
      if (c) {
        print('s');
      }
    }
  } else {
    print('s');
  }
}''');
  }

  Future<void> test_reports_on_three_if_else2() async {
    await assertDiagnostics(
      r'''
void threeIfElse2(bool a, bool b, bool c) {
  if (a) {
    if (b) {
      if (c) {
        print('s');
      }
    } else {
      print('s');
    }
  }
}''',
      [lint(46, 105)],
    );
  }

  Future<void> test_reports_on_three_if_else3() async {
    await assertDiagnostics(
      r'''
void threeIfElse3(bool a, bool b, bool c) {
  if (a) {
    if (b) {
      if (c) {
        print('s');
      } else {
        print('s');
      }
    }
  }
}''',
      [lint(46, 109)],
    );
  }

  Future<void> test_reports_on_two_seqential_if() async {
    await assertDiagnostics(
      r'''
void twoSeqentialIf(bool a, bool b) {
  if (a) return;
  if (b) {
    print('s');
  }
}''',
      [lint(57, 28)],
    );
  }

  Future<void> test_doesn_not_report_on_two_seqential_if_return() async {
    await assertNoDiagnostics(r'''
void twoSeqentialIfReturn(bool a, bool b) {
  if (a) return;
  if (b) return;

  return;
}''');
  }

  Future<void> test_reports_on_two_seqential_if_return2() async {
    await assertDiagnostics(
      r'''
void twoSeqentialIfReturn2(bool a, bool b) {
  //no lint
  if (a) return;
  if (b) {
    print('s');
  }

  return;
}''',
      [lint(76, 28)],
    );
  }

  Future<void> test_doesn_not_report_on_two_seqential_if_something() async {
    await assertNoDiagnostics(r'''
void twoSeqentialIfSomething(bool a, bool b) {
  if (a) return;
  if (b) {
    print('s');
  }

  print('s');
}''');
  }

  Future<void> test_reports_on_two_seqential_if_something2() async {
    await assertDiagnostics(
      r'''
void twoSeqentialIfSomething2(bool a, bool b) {
  //no lint
  if (a) {
    print('s');
  }
  if (b) {
    print('s');
  }
}''',
      [lint(93, 28)],
    );
  }

  Future<void> test_reports_on_three_seqential_if_return() async {
    await assertDiagnostics(
      r'''
void threeSeqentialIfReturn(bool a, bool b, bool c) {
  //no lint
  if (a) return;
  if (b) return;
  if (c) {
    print('s');
  }

  return;
}''',
      [lint(102, 28)],
    );
  }

  Future<void> test_reports_on_three_seqential_if_return2() async {
    await assertDiagnostics(
      r'''
void threeSeqentialIfReturn2(bool a, bool b, bool c) {
  //no lint
  if (a) return;
  //no lint
  if (b) {
    print('s');
  }
  if (c) {
    print('s');
  }
}''',
      [lint(129, 28)],
    );
  }

  Future<void> test_doesn_not_report_on_one_if_with_throw_with_return() async {
    await assertNoDiagnostics(r'''
void oneIfWithThrowWithReturn(bool a) {
  if (a) {
    throw '';
  }

  return;
}''');
  }

  Future<void> test_doesn_not_report_on_one_if_else_with_throw_return() async {
    await assertNoDiagnostics(r'''
void oneIfElseWithThrowReturn(bool a) {
  if (a) {
    print('s');
  } else {
    throw '';
  }
}''');
  }

  Future<void> test_reports_on_two_seqential_if_with_throw() async {
    await assertDiagnostics(
      r'''
void twoSeqentialIfWithThrow(bool a, bool b) {
  if (a) throw '';
  if (b) {
    print('s');
  }
}''',
      [lint(68, 28)],
    );
  }

  Future<void> test_reports_on_two_seqential_if_with_throw_return2() async {
    await assertDiagnostics(
      r'''
void twoSeqentialIfWithThrowReturn2(bool a, bool b) {
  //no lint
  if (a) throw '';
  if (b) {
    print('s');
  }

  return;
}''',
      [lint(87, 28)],
    );
  }

  Future<void> test_reports_on_three_seqential_if_with_throw_return() async {
    await assertDiagnostics(
      r'''
void threeSeqentialIfWithThrowReturn(bool a, bool b, bool c) {
  //no lint
  if (a) throw '';
  if (b) throw '';
  if (c) {
    print('s');
  }

  return;
}''',
      [lint(115, 28)],
    );
  }

  Future<void> test_reports_on_three_seqential_if_with_throw_return2() async {
    await assertDiagnostics(
      r'''
void threeSeqentialIfWithThrowReturn2(bool a, bool b, bool c) {
  //no lint
  if (a) throw '';
  //no lint
  if (b) {
    print('s');
  }
  if (c) {
    print('s');
  }
}''',
      [lint(140, 28)],
    );
  }
}
