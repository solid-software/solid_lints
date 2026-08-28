import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:analyzer_testing/utilities/utilities.dart';
import 'package:solid_lints/src/common/parameter_parser/analysis_options_loader.dart';
import 'package:solid_lints/src/lints/prefer_early_return/prefer_early_return_rule.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../../utils/auto_test_lint_offsets.dart';

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
    rule = PreferEarlyReturnRule(
      analysisOptionsLoader: AnalysisOptionsLoader(
        resourceProvider: resourceProvider,
      ),
    );
    super.setUp();
  }

  void _configureRule({int? maximumStatements, bool? ignoreIfCase}) {
    newAnalysisOptionsYamlFile(
      testPackageRootPath,
      '''${analysisOptionsContent(rules: [rule.name])}
plugins:
  solid_lints:
    diagnostics:
      prefer_early_return:
${maximumStatements != null ? '        maximum_statements: $maximumStatements\n' : ''}'''
      '''${ignoreIfCase != null ? '        ignore_if_case: $ignoreIfCase\n' : ''}''',
    );
  }

  Future<void> test_reports_if_as_only_statement_in_function() async {
    await assertAutoDiagnostics('''
void test(bool a) {
  ${expectLint('''if (a) {
    print('hello');
    print('world');
  }''')}
}
''');
  }

  Future<void> test_reports_if_with_return() async {
    await assertAutoDiagnostics('''
void test(bool a) {
  ${expectLint('''if (a) {
    print('hello');
    print('world');
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
    print('world');
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
    print('done');
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
    print('done');
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
      if (c) {
        print('nested');
      }
    }
    print('done');
  }''')}
}
''');
  }

  Future<void> test_reports_nested_3_with_return() async {
    await assertAutoDiagnostics('''
void test(bool a, bool b, bool c) {
  ${expectLint('''if (a) {
    if (b) {
      if (c) {
        print('nested');
      }
    }
    print('done');
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
    print('world');
  } else {
    print('hello');
    print('world');
  }
}
''');
  }

  Future<void> test_does_not_report_if_else_return() async {
    await assertNoDiagnostics(r'''
void test(bool a) {
  if (a) {
    print('hello');
    print('world');
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
    if (b) {
      print('hello');
      print('world');
    }
  } else {
    print('hello');
    print('world');
  }
}
''');
  }

  Future<void> test_reports_inner_if_else() async {
    await assertAutoDiagnostics('''
void test(bool a, bool b) {
  ${expectLint('''if (a) {
    if (b) {
      print('hello');
      print('world');
    } else {
      print('hello');
      print('world');
    }
    print('done');
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
        print('world');
      }
    }
    print('done');
  }''')}
}''');
  }

  Future<void> test_does_not_report_nested_3_with_else_1() async {
    await assertNoDiagnostics(r'''
void test(bool a, bool b, bool c) {
  if (a) {
    if (b) {
      if (c) {
        print('nested');
        print('done');
      }
    }
  } else {
    print('hello');
    print('world');
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
        print('done');
      }
    } else {
      print('nested');
      print('done');
    }
    print('done');
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
        print('done');
      } else {
        print('nested');
        print('done');
      }
    }
    print('done');
  }''')}
}
''');
  }

  Future<void> test_reports_2_sequencial_if() async {
    await assertAutoDiagnostics('''
void test(bool a, bool b) {
  if (a) return;
  ${expectLint('''if (b) {
    print('hello');
    print('world');
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
    print('world');
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
    print('world');
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
    print('world');
  }
  ${expectLint('''if (b) {
    print('hello');
    print('world');
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
    print('world');
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
    print('world');
  }
  ${expectLint('''if (c) {
    print('hello');
    print('world');
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

  Future<void> test_does_not_report_if_rethrow_with_return() async {
    await assertNoDiagnostics(r'''
void test(bool a) {
  try {
    print('hello');
  } catch (_) {
    if (a) {
      rethrow;
    }

    return;
  }
}
''');
  }

  Future<void> test_does_not_report_if_else_throw() async {
    await assertNoDiagnostics(r'''
void test(bool a) {
  if (a) {
    print('hello');
    print('world');
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
    print('world');
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
    print('world');
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
    print('world');
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
    print('world');
  }
  ${expectLint('''if (c) {
    print('hello');
    print('world');
  }''')}
}
''');
  }

  // --- Tests for maximum_statements parameter ---

  Future<void> test_does_not_report_single_statement_by_default() async {
    await assertNoDiagnostics(r'''
void test(bool a) {
  if (a) {
    print('hello');
  }
}
''');
  }

  Future<void>
  test_reports_single_statement_when_maximum_statements_zero() async {
    _configureRule(maximumStatements: 0);
    await assertAutoDiagnostics('''
void test(bool a) {
  ${expectLint('''if (a) {
    print('hello');
  }''')}
}
''');
  }

  Future<void>
  test_does_not_report_two_statements_when_maximum_statements_two() async {
    _configureRule(maximumStatements: 2);
    await assertNoDiagnostics(r'''
void test(bool a) {
  if (a) {
    print('one');
    print('two');
  }
}
''');
  }

  Future<void>
  test_reports_three_statements_when_maximum_statements_two() async {
    _configureRule(maximumStatements: 2);
    await assertAutoDiagnostics('''
void test(bool a) {
  ${expectLint('''if (a) {
    print('one');
    print('two');
    print('three');
  }''')}
}
''');
  }

  // --- Tests for ignore_if_case parameter ---

  Future<void> test_does_not_report_if_case_by_default() async {
    await assertNoDiagnostics(r'''
void test(Object? value) {
  if (value case String s) {
    print(s);
    print('done');
  }
}
''');
  }

  Future<void> test_reports_if_case_when_ignore_if_case_false() async {
    _configureRule(ignoreIfCase: false);
    await assertAutoDiagnostics('''
void test(Object? value) {
  ${expectLint('''if (value case String s) {
    print(s);
    print('done');
  }''')}
}
''');
  }

  // --- Tests for loop statements ---

  Future<void> test_reports_for_in_loop() async {
    await assertAutoDiagnostics('''
void test(List<String> items) {
  for (final item in items) {
    ${expectLint('''if (item.isNotEmpty) {
      print(item);
      print('done');
    }''')}
  }
}
''');
  }

  Future<void> test_reports_traditional_for_loop() async {
    await assertAutoDiagnostics('''
void test(List<String> items) {
  for (var i = 0; i < items.length; i++) {
    ${expectLint('''if (items[i].isNotEmpty) {
      print(items[i]);
      print('done');
    }''')}
  }
}
''');
  }

  Future<void> test_reports_while_loop() async {
    await assertAutoDiagnostics('''
void test(bool condition, bool ready) {
  while (condition) {
    ${expectLint('''if (ready) {
      print('ready');
      print('go');
    }''')}
  }
}
''');
  }

  Future<void> test_reports_do_while_loop() async {
    await assertAutoDiagnostics('''
void test(bool condition, bool ready) {
  do {
    ${expectLint('''if (ready) {
      print('ready');
      print('go');
    }''')}
  } while (condition);
}
''');
  }

  Future<void> test_reports_loop_with_trailing_continue() async {
    await assertAutoDiagnostics('''
void test(List<String> items) {
  for (final item in items) {
    ${expectLint('''if (item.isNotEmpty) {
      print(item);
      print('done');
    }''')}
    continue;
  }
}
''');
  }

  Future<void> test_does_not_report_loop_with_statement_after_if() async {
    await assertNoDiagnostics(r'''
void test(List<String> items) {
  for (final item in items) {
    if (item.isNotEmpty) {
      print(item);
      print('done');
    }
    print('after');
  }
}
''');
  }

  Future<void> test_does_not_report_loop_with_if_else() async {
    await assertNoDiagnostics(r'''
void test(List<String> items) {
  for (final item in items) {
    if (item.isNotEmpty) {
      print(item);
      print('done');
    } else {
      print('empty');
      print('done');
    }
  }
}
''');
  }

  Future<void> test_does_not_report_loop_with_continue_in_if() async {
    await assertNoDiagnostics(r'''
void test(List<String> items) {
  for (final item in items) {
    if (item.isNotEmpty) {
      print(item);
      continue;
    }
  }
}
''');
  }

  Future<void> test_does_not_report_loop_with_break_in_if() async {
    await assertNoDiagnostics(r'''
void test(List<String> items) {
  for (final item in items) {
    if (item.isNotEmpty) {
      print(item);
      break;
    }
  }
}
''');
  }

  Future<void> test_does_not_report_loop_with_rethrow_in_if() async {
    await assertNoDiagnostics(r'''
void test(List<String> items) {
  for (final item in items) {
    try {
      print('hello');
    } catch (_) {
      if (item.isNotEmpty) {
        print(item);
        rethrow;
      }
    }
  }
}
''');
  }

  Future<void> test_reports_if_with_closure_containing_return() async {
    await assertAutoDiagnostics('''
void test(bool a, List<int> items) {
  ${expectLint('''if (a) {
    final doubled = items.map((x) {
      return x * 2;
    });
    print(doubled);
  }''')}
}
''');
  }

  Future<void> test_reports_loop_with_nested_loop_containing_break() async {
    await assertAutoDiagnostics('''
void test(List<String> items, List<int> numbers) {
  for (final item in items) {
    ${expectLint('''if (item.isNotEmpty) {
      for (final n in numbers) {
        if (n > 0) break;
      }
      print(item);
    }''')}
  }
}
''');
  }

  Future<void> test_reports_loop_with_switch_containing_break() async {
    await assertAutoDiagnostics('''
void test(List<int> items) {
  for (final item in items) {
    ${expectLint('''if (item > 0) {
      switch (item) {
        case 1:
          break;
      }
      print(item);
    }''')}
  }
}
''');
  }

  Future<void>
  test_does_not_report_loop_with_switch_containing_continue() async {
    await assertNoDiagnostics(r'''
void test(List<int> items) {
  for (final item in items) {
    if (item > 0) {
      switch (item) {
        case 1:
          continue;
      }
      print(item);
    }
  }
}
''');
  }

  Future<void> test_reports_loop_with_single_if_body() async {
    await assertAutoDiagnostics('''
void test(List<String> items) {
  for (final item in items)
    ${expectLint('''if (item.isNotEmpty) {
      print(item);
      print('done');
    }''')}
}
''');
  }

  Future<void> test_reports_async_function() async {
    await assertAutoDiagnostics('''
Future<void> test(bool a) async {
  ${expectLint('''if (a) {
    print('hello');
    print('world');
  }''')}
}
''');
  }

  Future<void> test_reports_if_with_local_function_containing_return() async {
    await assertAutoDiagnostics('''
void test(bool a) {
  ${expectLint('''if (a) {
    void helper() {
      return;
    }
    helper();
    print('done');
  }''')}
}
''');
  }

  // --- Labeled break/continue edge cases ---

  Future<void>
  test_reports_loop_with_switch_containing_continue_to_case() async {
    await assertAutoDiagnostics('''
void test(List<int> items) {
  for (final item in items) {
    ${expectLint('''if (item > 0) {
      switch (item) {
        case 1:
          continue target;
        target:
        case 2:
          print('two');
      }
      print(item);
    }''')}
  }
}
''');
  }

  Future<void>
  test_does_not_report_loop_with_nested_loop_containing_continue_outer() async {
    await assertNoDiagnostics(r'''
void test(List<String> items, List<int> numbers) {
  outer:
  for (final item in items) {
    if (item.isNotEmpty) {
      for (final n in numbers) {
        continue outer;
      }
      print(item);
    }
  }
}
''');
  }

  Future<void>
  test_does_not_report_loop_with_nested_loop_containing_break_outer() async {
    await assertNoDiagnostics(r'''
void test(List<String> items, List<int> numbers) {
  outer:
  for (final item in items) {
    if (item.isNotEmpty) {
      for (final n in numbers) {
        break outer;
      }
      print(item);
    }
  }
}
''');
  }

  Future<void>
  test_does_not_report_loop_with_switch_containing_break_outer() async {
    await assertNoDiagnostics(r'''
void test(List<int> items) {
  outer:
  for (final item in items) {
    if (item > 0) {
      switch (item) {
        case 1:
          break outer;
      }
      print(item);
    }
  }
}
''');
  }
}
