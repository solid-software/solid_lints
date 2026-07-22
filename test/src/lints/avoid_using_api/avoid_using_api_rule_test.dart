import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:analyzer_testing/utilities/utilities.dart';
import 'package:solid_lints/src/common/parameter_parser/analysis_options_loader.dart';
import 'package:solid_lints/src/lints/avoid_using_api/avoid_using_api_rule.dart';
import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../../utils/auto_test_lint_offsets.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AvoidUsingApiRuleTest);
  });
}

@reflectiveTest
class AvoidUsingApiRuleTest extends AnalysisRuleTest with AutoTestLintOffsets {
  static const _mockMyDepContent = '''
class BadClass {
  const BadClass({int? badParam});
  const BadClass.named({int? badParam});
  void badMethod({int? badParam}) {}
}
class Holder {
  const Holder();
  BadClass get badClass => const BadClass();
}
int get badGlobal => 42;
void badFunction() {}
''';

  @override
  void setUp() {
    rule = AvoidUsingApiRule(
      analysisOptionsLoader: AnalysisOptionsLoader(
        resourceProvider: resourceProvider,
      ),
    );
    newPackage('my_dep')..addFile('lib/my_dep.dart', _mockMyDepContent);
    newPackage('other_dep')..addFile('lib/other_dep.dart', 'class BadClass {}');
    super.setUp();
  }

  void _configureRule(String entriesYaml) {
    newAnalysisOptionsYamlFile(testPackageRootPath, '''
${analysisOptionsContent(rules: [rule.name])}
plugins:
  solid_lints:
    diagnostics:
      avoid_using_api:
        entries:
$entriesYaml''');
  }

  Future<void> test_reports_ban_source() {
    _configureRule('''
          - source: package:my_dep/my_dep.dart
''');

    return assertAutoDiagnostics('''
import 'package:my_dep/my_dep.dart';

void fn() {
  final a = ${expectLint('BadClass')}();
  final b = ${expectLint('badGlobal')};
  ${expectLint('badFunction')}();
}
''');
  }

  Future<void> test_reports_ban_class_from_source() {
    _configureRule('''
          - class_name: BadClass
            source: package:my_dep/my_dep.dart
''');

    return assertAutoDiagnostics('''
import 'package:my_dep/my_dep.dart';

void fn() {
  ${expectLint('BadClass')} ${expectLint('a')} = ${expectLint('BadClass')}();
  final b = badGlobal;
}
''');
  }

  Future<void> test_reports_ban_id_from_source() {
    _configureRule('''
          - identifier: badGlobal
            source: package:my_dep/my_dep.dart
''');

    return assertAutoDiagnostics('''
import 'package:my_dep/my_dep.dart';

void fn() {
  final a = BadClass();
  final b = ${expectLint('badGlobal')};
  badFunction();
}
''');
  }

  Future<void> test_reports_ban_id_from_class_from_source() {
    _configureRule('''
          - class_name: BadClass
            identifier: badMethod
            source: package:my_dep/my_dep.dart
''');

    return assertAutoDiagnostics('''
import 'package:my_dep/my_dep.dart';

void fn() {
  final a = BadClass();
  a.${expectLint('badMethod')}();
}
''');
  }

  Future<void> test_reports_ban_default_constructor() {
    _configureRule('''
          - class_name: BadClass
            identifier: "()"
            source: package:my_dep/my_dep.dart
''');

    return assertAutoDiagnostics('''
import 'package:my_dep/my_dep.dart';

void fn() {
  final a = ${expectLint('BadClass')}();
  final b = BadClass.named();
}
''');
  }

  Future<void> test_reports_ban_usage_with_specific_named_parameter() {
    _configureRule('''
          - class_name: BadClass
            identifier: badMethod
            named_parameter: badParam
            source: package:my_dep/my_dep.dart
''');

    return assertAutoDiagnostics('''
import 'package:my_dep/my_dep.dart';

void fn() {
  final a = BadClass();
  a.${expectLint('badMethod')}(badParam: 123);
  a.badMethod(); // OK
}
''');
  }

  Future<void> test_respects_exclude_patterns() {
    _configureRule('''
          - class_name: BadClass
            source: package:my_dep/my_dep.dart
            excludes:
              - "lib/src/**"
''');

    // Create a file in a folder matching the exclude pattern
    final excludedFilePath = '$testPackageRootPath/lib/src/excluded_test.dart';
    newFile(excludedFilePath, '''
import 'package:my_dep/my_dep.dart';
void fn() {
  BadClass a = BadClass();
}
''');

    // Verify no diagnostics in the excluded file
    return assertNoDiagnosticsInFile(excludedFilePath);
  }

  Future<void> test_reports_ban_id_from_class_from_source_chained() {
    _configureRule('''
          - class_name: BadClass
            identifier: badMethod
            source: package:my_dep/my_dep.dart
''');

    return assertAutoDiagnostics('''
import 'package:my_dep/my_dep.dart';

void fn() {
  final h = const Holder();
  h.badClass.${expectLint('badMethod')}();
}
''');
  }

  Future<void> test_reports_ban_class_from_source_chained() {
    _configureRule('''
          - class_name: BadClass
            source: package:my_dep/my_dep.dart
''');

    return assertAutoDiagnostics('''
import 'package:my_dep/my_dep.dart';

void fn() {
  final h = const Holder();
  h.badClass.${expectLint('badMethod')}();
}
''');
  }

  Future<void> test_reports_ban_source_with_custom_reason() {
    _configureRule('''
          - source: package:my_dep/my_dep.dart
            reason: "Custom warning message"
''');

    return assertAutoDiagnostics('''
import 'package:my_dep/my_dep.dart';

void fn() {
  final a = ${expectLint('BadClass', messageContainsAll: ["Custom warning message"])}();
}
''');
  }

  Future<void> test_does_not_report_same_names_from_other_source() {
    _configureRule('''
          - class_name: BadClass
            source: package:my_dep/my_dep.dart
''');

    return assertNoDiagnostics('''
import 'package:other_dep/other_dep.dart';

void fn() {
  final a = BadClass(); // OK
}
''');
  }

  Future<void> test_reports_ban_extension_method() {
    newPackage('my_dep')..addFile('lib/my_dep.dart', '''
extension BadExtension on String {
  void badExtMethod() {}
}
''');

    _configureRule('''
          - class_name: BadExtension
            identifier: badExtMethod
            source: package:my_dep/my_dep.dart
''');

    return assertAutoDiagnostics('''
import 'package:my_dep/my_dep.dart';

void fn() {
  "".${expectLint('badExtMethod')}();
}
''');
  }

  Future<void> test_reports_ban_static_method() {
    newPackage('my_dep')..addFile('lib/my_dep.dart', '''
class BadClass {
  static void staticBadMethod() {}
}
''');

    _configureRule('''
          - class_name: BadClass
            identifier: staticBadMethod
            source: package:my_dep/my_dep.dart
''');

    return assertAutoDiagnostics('''
import 'package:my_dep/my_dep.dart';

void fn() {
  BadClass.${expectLint('staticBadMethod')}();
}
''');
  }

  Future<void> test_respects_include_patterns() {
    _configureRule('''
          - class_name: BadClass
            source: package:my_dep/my_dep.dart
            includes:
              - "**/test.dart"
''');

    // Create a file not matching the include pattern
    final otherFilePath = '$testPackageRootPath/lib/other.dart';
    newFile(otherFilePath, '''
import 'package:my_dep/my_dep.dart';
void fn() {
  final a = BadClass();
}
''');

    return assertAutoDiagnostics('''
import 'package:my_dep/my_dep.dart';
void fn() {
  final ${expectLint('a')} = ${expectLint('BadClass')}();
}
''').then((_) => assertNoDiagnosticsInFile(otherFilePath));
  }

  Future<void>
  test_reports_ban_usage_with_specific_named_parameter_in_constructors() {
    _configureRule('''
          - class_name: BadClass
            identifier: "()"
            named_parameter: badParam
            source: package:my_dep/my_dep.dart
          - class_name: BadClass
            identifier: named
            named_parameter: badParam
            source: package:my_dep/my_dep.dart
''');

    return assertAutoDiagnostics('''
import 'package:my_dep/my_dep.dart';

void fn() {
  final a = ${expectLint('BadClass')}(badParam: 123);
  final b = BadClass(); // OK
  final c = ${expectLint('BadClass')}.named(badParam: 123);
  final d = BadClass.named(); // OK
}
''');
  }

  Future<void> test_reports_ban_extension_getter() {
    newPackage('my_dep')..addFile('lib/my_dep.dart', '''
extension BadExtension on String {
  String get badExtGetter => '';
}
''');

    _configureRule('''
          - class_name: BadExtension
            identifier: badExtGetter
            source: package:my_dep/my_dep.dart
''');

    return assertAutoDiagnostics('''
import 'package:my_dep/my_dep.dart';

void fn() {
  final val = "".${expectLint('badExtGetter')};
}
''');
  }

  Future<void> test_reports_ban_with_custom_severities() async {
    newAnalysisOptionsYamlFile(testPackageRootPath, '''
${analysisOptionsContent(rules: [rule.name])}
plugins:
  solid_lints:
    diagnostics:
      avoid_using_api:
        avoid_using_api: true
        severity: warning
        entries:
          - class_name: BadClass
            source: package:my_dep/my_dep.dart
            severity: error
          - identifier: badGlobal
            source: package:my_dep/my_dep.dart
            severity: info
          - identifier: badFunction
            source: package:my_dep/my_dep.dart
''');

    await assertAutoDiagnostics('''
import 'package:my_dep/my_dep.dart';

void fn() {
  final ${expectLint('a')} = ${expectLint('BadClass')}();
  final b = ${expectLint('badGlobal')};
  ${expectLint('badFunction')}();
}
''');

    final diagnostics = result.diagnostics
        .where((d) => d.diagnosticCode.lowerCaseName == 'avoid_using_api')
        .toList();

    diagnostics.sort((first, second) => first.offset.compareTo(second.offset));

    expect(diagnostics, hasLength(4));
    expect(diagnostics[0].severity.name, 'error');
    expect(diagnostics[1].severity.name, 'error');
    expect(diagnostics[2].severity.name, 'info');
    expect(diagnostics[3].severity.name, 'warning');
  }

  Future<void> test_does_not_crash_on_invalid_entry_types() async {
    _configureRule('''
          - "not_a_map"
          - 123
          - class_name: BadClass
            source: package:my_dep/my_dep.dart
    ''');

    return assertAutoDiagnostics('''
import 'package:my_dep/my_dep.dart';

void fn() {
  final ${expectLint('a')} = ${expectLint('BadClass')}();
}
''');
  }
}
