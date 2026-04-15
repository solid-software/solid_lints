import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:solid_lints/src/lints/avoid_debug_print_in_release/avoid_debug_print_in_release_rule.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AvoidDebugPrintInReleaseRuleTest);
  });
}

@reflectiveTest
class AvoidDebugPrintInReleaseRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    // We only need the parts of foundation.dart that our rule cares about.
    newPackage('flutter')..addFile('lib/foundation.dart', r'''
    const bool kReleaseMode = false;
    const bool kDebugMode = true;
    void debugPrint(String? message) {}
  ''');

    rule = AvoidDebugPrintInReleaseRule();

    super.setUp();
  }

  void test_reports_debug_print_with_package_import() async {
    await assertDiagnostics(
      r'''
import 'package:flutter/foundation.dart';

void test() {
  debugPrint('This should be flagged');
}
''',
      [lint(59, 10)],
    );
  }

  void test_reports_aliased_debug_print_from_package() async {
    await assertDiagnostics(
      r'''import 'package:flutter/foundation.dart' as f;
void test() {
  f.debugPrint('This should be flagged');
}''',
      [lint(65, 10)],
    );
  }

  void test_reports_debug_print_as_callback() async {
    await assertDiagnostics(
      r'''
import 'package:flutter/foundation.dart';
void test() {
  ['a'].forEach(debugPrint);
}
''',
      [lint(72, 10)],
    );
  }

  void test_does_not_report_guarded_call() async {
    await assertNoDiagnostics(
      r'''
import 'package:flutter/foundation.dart';

void test() {
  if (!kReleaseMode) {
    debugPrint('This is safe');
  }
}
''',
    );
  }

  void test_does_not_report_inside_kDebugMode() async {
    await assertNoDiagnostics(
      r'''
import 'package:flutter/foundation.dart';
void test() {
  if (kDebugMode) {
    debugPrint('Safe');
  }
}
''',
    );
  }
}
