import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:analyzer_testing/utilities/utilities.dart';
import 'package:solid_lints/src/common/parameter_parser/analysis_options_loader.dart';
import 'package:solid_lints/src/lints/prefer_match_file_name/prefer_match_file_name_rule.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../../utils/auto_test_lint_offsets.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(PreferMatchFileNameRuleTest);
  });
}

@reflectiveTest
class PreferMatchFileNameRuleTest extends AnalysisRuleTest
    with AutoTestLintOffsets {
  static const _excludeEntitiesOptions = '''
plugins:
  solid_lints:
    diagnostics:
      prefer_match_file_name:
        exclude_entity:
          - extension
          - enum
          - mixin
          - extension_type
''';

  @override
  void setUp() {
    rule = PreferMatchFileNameRule(
      analysisOptionsLoader: AnalysisOptionsLoader(
        resourceProvider: resourceProvider,
      ),
    );
    super.setUp();
  }

  void test_does_not_report_when_class_name_matches_file_name() async {
    await assertNoDiagnostics(r'''
class Test {}
''');
  }

  void test_reports_when_class_name_does_not_match_file_name() async {
    await assertAutoDiagnostics('''
class ${expectLint('WrongClass')} {}
''');
  }

  void test_does_not_report_on_private_class() async {
    await assertNoDiagnostics(r'''
class _PrivateClass {}

class Test {}
''');
  }

  void test_reports_on_first_public_element_with_mismatch() async {
    await assertAutoDiagnostics('''
class _AnotherPrivateClass {}

class ${expectLint('WrongClass')} {}

class PreferMatchFileNameWrongTest {}
''');
  }

  void test_reports_enum_name_mismatch() async {
    await assertAutoDiagnostics('''
enum ${expectLint('WrongEnum')} { a, b }
''');
  }

  void test_reports_mixin_name_mismatch() async {
    await assertAutoDiagnostics('''
mixin ${expectLint('WrongMixin')} {}
''');
  }

  void test_reports_extension_name_mismatch() async {
    await assertAutoDiagnostics('''
extension ${expectLint('WrongExtension')} on List {}
''');
  }

  void test_reports_extension_type_mismatch() async {
    await assertAutoDiagnostics('''
extension type ${expectLint('WrongExtensionType')}(int id) {}
''');
  }

  void test_does_not_report_on_private_enum() async {
    await assertNoDiagnostics(r'''
enum _PrivateEnum { a, b }

class Test {}
''');
  }

  void test_does_not_report_on_private_mixin() async {
    await assertNoDiagnostics(r'''
mixin _PrivateMixin {}

class Test {}
''');
  }

  void test_does_not_report_on_private_extension() async {
    await assertNoDiagnostics(r'''
extension _PrivateExtension on String {}

class Test {}
''');
  }

  void test_does_not_report_on_extension_when_excluded() async {
    newAnalysisOptionsYamlFile(testPackageRootPath, '''
${analysisOptionsContent(rules: [rule.name])}
$_excludeEntitiesOptions''');
    await assertAutoDiagnostics('''
extension Ignored on String {}

extension IgnoredAgain on String {}

abstract class ${expectLint('WrongNamedClass')} {}

class PreferMatchFileNameIgnoreExtensions {}
''');
  }

  void test_does_not_report_on_enum_when_excluded() async {
    newAnalysisOptionsYamlFile(testPackageRootPath, '''
${analysisOptionsContent(rules: [rule.name])}
$_excludeEntitiesOptions''');
    await assertAutoDiagnostics('''
enum Ignored { _ }

enum IgnoredAgain { _ }

abstract class ${expectLint('WrongNamedClass')} {}

class PreferMatchFileNameIgnoreExtensions {}
''');
  }

  void test_does_not_report_on_mixin_when_excluded() async {
    newAnalysisOptionsYamlFile(testPackageRootPath, '''
${analysisOptionsContent(rules: [rule.name])}
$_excludeEntitiesOptions''');
    await assertAutoDiagnostics('''
mixin IgnoredMixin {}

abstract class ${expectLint('WrongNamedClass')} {}

class PreferMatchFileNameIgnoreExtensions {}
''');
  }

  void test_does_not_report_on_extension_type_when_excluded() async {
    newAnalysisOptionsYamlFile(testPackageRootPath, '''
${analysisOptionsContent(rules: [rule.name])}
$_excludeEntitiesOptions''');
    await assertAutoDiagnostics('''
extension type IgnoredExtensionType(int i) {}

abstract class ${expectLint('WrongNamedClass')} {}

class PreferMatchFileNameIgnoreExtensions {}
''');
  }

  void test_does_not_report_on_private_extension_type() async {
    await assertNoDiagnostics(r'''
extension type _PrivateExtensionType(int id) {}

class Test {}
''');
  }

  void test_does_not_report_on_unnamed_extension() async {
    await assertNoDiagnostics(r'''
extension on String {
  void hello() {}
}

class Test {}
''');
  }

  void test_does_not_report_on_empty_file() async {
    await assertNoDiagnostics(r'''
// Only comments
''');
  }

  void test_does_not_report_on_file_with_only_top_level_members() async {
    await assertNoDiagnostics(r'''
void someFunction() {}
final someVariable = 42;
''');
  }

  void test_does_not_report_on_multiple_public_declarations_if_first_matches() async {
    await assertNoDiagnostics(r'''
class Test {}
class AnotherPublicClass {}
''');
  }

  void test_reports_when_only_private_class_does_not_match_file_name() async {
    await assertAutoDiagnostics('''
class ${expectLint('_WrongPrivateClass')} {}
''');
  }

  void test_does_not_report_on_only_private_class_when_matching() async {
    await assertNoDiagnostics(r'''
class _Test {}
''');
  }
}
