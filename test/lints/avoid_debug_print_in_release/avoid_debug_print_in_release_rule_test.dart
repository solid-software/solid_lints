import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:solid_lints/src/lints/avoid_debug_print_in_release/avoid_debug_print_in_release_rule.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../auto_test_lint_offsets.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AvoidDebugPrintInReleaseRuleTest);
  });
}

@reflectiveTest
class AvoidDebugPrintInReleaseRuleTest extends AnalysisRuleTest
    with AutoTestLintOffsets {
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

  Future<void> test_reports_debug_print_with_package_import() async {
    await assertAutoDiagnostics('''
import 'package:flutter/foundation.dart';

void test() {
  ${expectLint('debugPrint')}('This should be flagged');
}
''');
  }

  Future<void> test_reports_aliased_debug_print_from_package() async {
    await assertAutoDiagnostics('''
import 'package:flutter/foundation.dart' as f;

void test() {
  f.${expectLint('debugPrint')}('This should be flagged');
}
''');
  }

  Future<void> test_reports_debug_print_as_callback() async {
    await assertAutoDiagnostics('''
import 'package:flutter/foundation.dart';

void test() {
  ['a'].forEach(${expectLint('debugPrint')});
}
''');
  }

  Future<void> test_reports_inside_kReleaseMode_guard() async {
    await assertAutoDiagnostics('''
import 'package:flutter/foundation.dart';

void test() {
  if (kReleaseMode) {
    ${expectLint('debugPrint')}('This should be flagged');
  }
}
''');
  }

  Future<void> test_reports_inside_not_kDebugMode_guard() async {
    await assertAutoDiagnostics('''
import 'package:flutter/foundation.dart';

void test() {
  if (!kDebugMode) {
    ${expectLint('debugPrint')}('Should still be flagged');
  }
}
''');
  }

  Future<void> test_does_not_report_inside_not_kReleaseMode() async {
    await assertNoDiagnostics(r'''
import 'package:flutter/foundation.dart';

void test() {
  if (!kReleaseMode) {
    debugPrint('Safe');
  }
}
''');
  }

  Future<void> test_does_not_report_inside_kDebugMode() async {
    await assertNoDiagnostics(r'''
import 'package:flutter/foundation.dart';

void test() {
  if (kDebugMode) {
    debugPrint('Safe');
  }
}
''');
  }

  Future<void> test_no_report_when_debugPrint_is_not_from_foundation() async {
    await assertNoDiagnostics(r'''
void debugPrint(String message) {}

void test() {
  debugPrint('Not a flutter call');
}
''');
  }

  Future<void> test_reports_when_imported_via_material() async {
    await assertAutoDiagnostics('''
import 'package:flutter/material.dart';

void test() {
  ${expectLint('debugPrint')}('Flagged via material');
}
''');
  }

  Future<void> test_reports_when_imported_via_cupertino() async {
    await assertAutoDiagnostics('''
import 'package:flutter/cupertino.dart';

void test() {
  ${expectLint('debugPrint')}('Flagged via cupertino');
}
''');
  }

  Future<void> test_reports_debug_print_call_method() async {
    await assertAutoDiagnostics('''
import 'package:flutter/foundation.dart';

void test() {
  ${expectLint('debugPrint')}.call('This should be flagged');
}
''');
  }
}
