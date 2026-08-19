import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:analyzer_testing/utilities/utilities.dart';
import 'package:solid_lints/src/common/parameter_parser/analysis_options_loader.dart';
import 'package:solid_lints/src/lints/avoid_non_null_assertion/avoid_non_null_assertion_rule.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../../utils/auto_test_lint_offsets.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AvoidNonNullAssertionRuleTest);
  });
}

@reflectiveTest
class AvoidNonNullAssertionRuleTest extends AnalysisRuleTest
    with AutoTestLintOffsets {
  static const _mockAnalysisOptionsContent = '''
plugins:
  solid_lints:
    diagnostics:
      avoid_non_null_assertion:
        ignored_types:
          - Map
          - IMap
          - BuiltMap
  ''';

  @override
  void setUp() {
    rule = AvoidNonNullAssertionRule(
      analysisOptionsLoader: AnalysisOptionsLoader(
        resourceProvider: resourceProvider,
      ),
    );
    super.setUp();

    newAnalysisOptionsYamlFile(
      testPackageRootPath,
      '''${analysisOptionsContent(rules: [rule.name])}
$_mockAnalysisOptionsContent''',
    );
  }

  Future<void> test_reports_non_null_assertion_on_nullable_value() async {
    await assertAutoDiagnostics('''
void m(int? number) {
  final value = ${expectLint('number!')};
}
''');
  }

  Future<void> test_reports_non_null_assertion_on_method_call() async {
    await assertAutoDiagnostics('''
void m(Object? object) {
  ${expectLint('object!')}.toString();
}
''');
  }

  Future<void> test_reports_map_access_when_not_ignored() async {
    newAnalysisOptionsYamlFile(
      testPackageRootPath,
      analysisOptionsContent(rules: [rule.name]),
    );
    await assertAutoDiagnostics('''
void m() {
  final map = {'key': 'value'};
  ${expectLint("map['key']!")};
}
''');
  }

  Future<void> test_reports_parenthesized_map_access_when_not_ignored() async {
    newAnalysisOptionsYamlFile(
      testPackageRootPath,
      analysisOptionsContent(rules: [rule.name]),
    );
    await assertAutoDiagnostics('''
void m() {
  final map = {'key': 'value'};
  ${expectLint("(map['key'])!")};
}
''');
  }

  Future<void> test_does_not_report_map_access() async {
    await assertNoDiagnostics(r'''
void m() {
  final map = {'key': 'value'};
  map['key']!;
}
''');
  }

  Future<void> test_does_not_report_parenthesized_map_access() async {
    await assertNoDiagnostics(r'''
void m() {
  final map = {'key': 'value'};
  (map['key'])!;
}
''');
  }

  Future<void> test_does_not_report_safe_null_check() async {
    await assertNoDiagnostics(r'''
void m(int? number) {
  if (number != null) {
    final value = number;
  }
}
''');
  }

  Future<void> test_does_not_report_imap_access() async {
    await assertNoDiagnostics(r'''
class IMap<K, V> {
  V? operator [](K key) => null;
}

void m(IMap<String, String> map) {
  map['key']!;
}
''');
  }

  Future<void> test_does_not_report_imap_access_with_single_string() async {
    newAnalysisOptionsYamlFile(
      testPackageRootPath,
      '''${analysisOptionsContent(rules: [rule.name])}
plugins:
  solid_lints:
    diagnostics:
      avoid_non_null_assertion:
        ignored_types: IMap''',
    );
    await assertNoDiagnostics(r'''
class IMap<K, V> {
  V? operator [](K key) => null;
}

void m(IMap<String, String> map) {
  map['key']!;
}
''');
  }
}
