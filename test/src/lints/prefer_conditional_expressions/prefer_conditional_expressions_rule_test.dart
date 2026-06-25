import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:analyzer_testing/utilities/utilities.dart';
import 'package:solid_lints/src/common/parameter_parser/analysis_options_loader.dart';
import 'package:solid_lints/src/lints/prefer_conditional_expressions/prefer_conditional_expressions_rule.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../../../lints/auto_test_lint_offsets.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(PreferConditionalExpressionsRuleTest);
  });
}

@reflectiveTest
class PreferConditionalExpressionsRuleTest extends AnalysisRuleTest
    with AutoTestLintOffsets {
  @override
  void setUp() {
    rule = PreferConditionalExpressionsRule(
      analysisOptionsLoader: AnalysisOptionsLoader(
        resourceProvider: resourceProvider,
      ),
    );
    super.setUp();
  }

  Future<void> test_reports_on_simple_assignment() async {
    await assertAutoDiagnostics('''
void main() {
  var x = 0;
  ${expectLint('''if (x > 0) {
    x = 1;
  } else {
    x = 2;
  }''')}
}
''');
  }

  Future<void> test_reports_on_simple_return() async {
    await assertAutoDiagnostics('''
int getVal(int x) {
  ${expectLint('''if (x > 0) {
    return 1;
  } else {
    return 2;
  }''')}
}
''');
  }

  Future<void> test_does_not_report_when_different_variables_assigned() async {
    await assertNoDiagnostics('''
void main() {
  var x = 0;
  var y = 0;
  if (x > 0) {
    x = 1;
  } else {
    y = 2;
  }
}
''');
  }

  Future<void> test_does_not_report_when_no_else_clause() async {
    await assertNoDiagnostics('''
void main() {
  var x = 0;
  if (x > 0) {
    x = 1;
  }
}
''');
  }

  Future<void> test_reports_on_same_compound_assignment() async {
    await assertAutoDiagnostics('''
void main() {
  var x = 0;
  ${expectLint('''if (x > 0) {
    x += 1;
  } else {
    x += 2;
  }''')}
}
''');
  }

  Future<void> test_does_not_report_on_different_compound_assignment() async {
    await assertNoDiagnostics('''
void main() {
  var x = 0;
  if (x > 0) {
    x += 1;
  } else {
    x -= 2;
  }
}
''');
  }

  Future<void> test_does_not_report_on_mixed_assignment_operators() async {
    await assertNoDiagnostics('''
void main() {
  var x = 0;
  if (x > 0) {
    x += 1;
  } else {
    x = 2;
  }
}
''');
  }

  Future<void> test_does_not_report_on_empty_returns() async {
    await assertNoDiagnostics('''
void test(bool c) {
  if (c) {
    return;
  } else {
    return;
  }
}
''');
  }

  Future<void> test_does_not_report_on_mixed_empty_return() async {
    await assertNoDiagnostics('''
dynamic test(bool c) {
  if (c) {
    return 1;
  } else {
    return;
  }
}
''');
  }

  Future<void> test_reports_on_nested_by_default() async {
    await assertAutoDiagnostics('''
void main() {
  var x = 0;
  ${expectLint('''if (x > 0) {
    x = x > 2 ? 3 : 4;
  } else {
    x = 2;
  }''')}
}
''');
  }

  Future<void> test_does_not_report_on_nested_when_ignore_nested_true() async {
    newAnalysisOptionsYamlFile(
      testPackageRootPath,
      '''${analysisOptionsContent(rules: [rule.name])}
plugins:
  solid_lints:
    diagnostics:
      prefer_conditional_expressions:
        ignore_nested: true
''',
    );
    await assertNoDiagnostics('''
void main() {
  var x = 0;
  if (x > 0) {
    x = x > 2 ? 3 : 4;
  } else {
    x = 2;
  }
}
''');
  }
}
