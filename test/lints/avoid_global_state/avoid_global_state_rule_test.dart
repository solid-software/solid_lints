import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:solid_lints/src/lints/avoid_global_state/avoid_global_state_rule.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../auto_test_lint_offsets.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AvoidGlobalStateRuleTest);
  });
}

@reflectiveTest
class AvoidGlobalStateRuleTest extends AnalysisRuleTest
    with AutoTestLintOffsets {
  @override
  void setUp() {
    rule = AvoidGlobalStateRule();
    super.setUp();
  }

  Future<void> test_reports_mutable_top_level_variable() async {
    await assertAutoDiagnostics('''
var ${expectLint('globalMutable = 0')};
''');
  }

  Future<void> test_reports_mutable_static_field() async {
    await assertAutoDiagnostics('''
class Test {
  static int ${expectLint('staticMutable = 0')};
}
''');
  }

  Future<void> test_does_not_report_global_immutable_variables() async {
    await assertNoDiagnostics(r'''
final globalFinal = 1;
const globalConst = 1;
''');
  }

  Future<void> test_does_not_report_global_private_variables() async {
    await assertNoDiagnostics(r'''
var _privateTopLevel = 0;
''');
  }

  Future<void> test_does_not_report_class_level_immutable_variables() async {
    await assertNoDiagnostics(r'''
class Test {
  static final int staticFinal = 1;
  static const int staticConst = 2;
}
''');
  }

  Future<void> test_does_not_report_class_level_private_variables() async {
    await assertNoDiagnostics(r'''
class Test {
  static int _staticPrivate = 0;
}
''');
  }

  Future<void> test_does_not_report_local_variables() async {
    await assertNoDiagnostics(r'''
void m() {
  int localMutable = 0;
}
''');
  }
}
