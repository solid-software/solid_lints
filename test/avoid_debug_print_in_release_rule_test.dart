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
    final flutter = newPackage('flutter');

    flutter.addFile('lib/foundation.dart', r'''
const bool kReleaseMode = false;
const bool kDebugMode = true;
void debugPrint(String? message) {}
''');

    flutter.addFile('lib/material.dart', r'''
export 'package:flutter/foundation.dart';
''');

    flutter.addFile('lib/cupertino.dart', r'''
export 'package:flutter/foundation.dart';
''');

    rule = AvoidDebugPrintInReleaseRule();

    super.setUp();
  }

  @override
  String get analysisRule => AvoidDebugPrintInReleaseRule.lintName;

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
      r'''
import 'package:flutter/foundation.dart' as f;

void test() {
  f.debugPrint('This should be flagged');
}
''',
      [lint(66, 10)],
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
      [lint(73, 10)],
    );
  }

  void test_reports_inside_kReleaseMode_guard() async {
    await assertDiagnostics(
      r'''
import 'package:flutter/foundation.dart';

void test() {
  if (kReleaseMode) {
    debugPrint('This should be flagged');
  }
}
''',
      [lint(83, 10)],
    );
  }

  void test_reports_inside_not_kDebugMode_guard() async {
    await assertDiagnostics(
      r'''
import 'package:flutter/foundation.dart';

void test() {
  if (!kDebugMode) {
    debugPrint('Should still be flagged');
  }
}
''',
      [lint(82, 10)],
    );
  }

  void test_does_not_report_inside_not_kReleaseMode() async {
    await assertNoDiagnostics(
      r'''
import 'package:flutter/foundation.dart';

void test() {
  if (!kReleaseMode) {
    debugPrint('Safe');
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

  void test_no_report_when_debugPrint_is_not_from_foundation() async {
    await assertNoDiagnostics(
      r'''
void debugPrint(String message) {}

void test() {
  debugPrint('Not a flutter call');
}
''',
    );
  }

  void test_reports_when_imported_via_material() async {
    await assertDiagnostics(
      r'''
import 'package:flutter/material.dart';

void test() {
  debugPrint('Flagged via material');
}
''',
      [lint(57, 10)],
    );
  }

  void test_reports_when_imported_via_cupertino() async {
    await assertDiagnostics(
      r'''
import 'package:flutter/cupertino.dart';

void test() {
  debugPrint('Flagged via cupertino');
}
''',
      [lint(58, 10)],
    );
  }

  void test_reports_debug_print_call_method() async {
    await assertDiagnostics(
      r'''
import 'package:flutter/foundation.dart';

void test() {
  debugPrint.call('This should be flagged');
}
''',
      [lint(59, 10)],
    );
  }
}
