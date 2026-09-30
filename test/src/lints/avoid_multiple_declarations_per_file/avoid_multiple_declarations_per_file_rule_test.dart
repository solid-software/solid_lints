import 'dart:convert';

import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:analyzer_testing/utilities/utilities.dart';
import 'package:solid_lints/src/common/parameter_parser/analysis_options_loader.dart';
import 'package:solid_lints/src/lints/avoid_multiple_declarations_per_file/avoid_multiple_declarations_per_file_rule.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../../utils/auto_test_lint_offsets.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AvoidMultipleDeclarationsPerFileRuleTest);
  });
}

@reflectiveTest
class AvoidMultipleDeclarationsPerFileRuleTest extends AnalysisRuleTest
    with AutoTestLintOffsets {
  @override
  void setUp() {
    rule = AvoidMultipleDeclarationsPerFileRule(
      analysisOptionsLoader: AnalysisOptionsLoader(
        resourceProvider: resourceProvider,
      ),
    );
    super.setUp();

    newFile('$testPackageLibPath/base.dart', r'''
abstract class Base {}
mixin Mix {}
''');

    newFile('$testPackageLibPath/flutter.dart', r'''
abstract class StatefulWidget {}
abstract class State<T extends StatefulWidget> {}
''');
  }

  void _configureRule({
    List<String>? ignoredTypes,
    List<String>? excludeEntity,
    bool? allowPrivate,
    int? maximumLoc,
  }) {
    final options = jsonEncode({
      'ignored_types': ?ignoredTypes,
      'exclude_entity': ?excludeEntity,
      'allow_private': ?allowPrivate,
      'maximum_loc': ?maximumLoc,
    });

    newAnalysisOptionsYamlFile(testPackageRootPath, '''
${analysisOptionsContent(rules: [rule.name])}
plugins:
  solid_lints:
    diagnostics:
      ${rule.name}: $options''');
  }

  // ---------------------------------------------------------------------------
  // Single & Non-Nominal Declarations
  // ---------------------------------------------------------------------------

  Future<void> test_does_not_report_on_single_declaration() async {
    await assertNoDiagnostics(r'''
class Test {}
''');
  }

  Future<void> test_does_not_report_on_non_nominal_declarations() async {
    await assertNoDiagnostics(r'''
typedef JsonMap = Map<String, Object?>;

class Test {}

void topLevelHelper() {}

const timeoutSeconds = 30;
''');
  }

  // ---------------------------------------------------------------------------
  // File Name Matching & Priority
  // ---------------------------------------------------------------------------

  Future<void> test_reports_class_when_matching_class_is_not_first() async {
    await assertAutoDiagnostics('''
class ${expectLint('Helper')} {}

class Test {}
''');
  }

  Future<void> test_reports_secondary_when_no_class_matches_file_name() async {
    await assertAutoDiagnostics('''
class FirstHelper {}

class ${expectLint('SecondHelper')} {}
''');
  }

  // ---------------------------------------------------------------------------
  // Violations Reported by Default
  // ---------------------------------------------------------------------------

  Future<void> test_reports_secondary_class() async {
    await assertAutoDiagnostics('''
class Test {}

class ${expectLint('SecondClass')} {}
''');
  }

  Future<void> test_reports_all_secondary_classes() async {
    await assertAutoDiagnostics('''
class Test {}

class ${expectLint('SecondClass')} {}

class ${expectLint('ThirdClass')} {}
''');
  }

  Future<void> test_reports_class_type_alias() async {
    await assertAutoDiagnostics('''
import 'base.dart';

class Test {}

class ${expectLint('TestAlias')} = Base with Mix;
''');
  }

  Future<void> test_reports_enum() async {
    await assertAutoDiagnostics('''
class Test {}

enum ${expectLint('TestRole')} { admin, user }
''');
  }

  Future<void> test_reports_mixin() async {
    await assertAutoDiagnostics('''
class Test {}

mixin ${expectLint('LoggingMixin')} {}
''');
  }

  Future<void> test_reports_extension() async {
    await assertAutoDiagnostics('''
class Test {}

extension ${expectLint('TestFormatting')} on Test {}
''');
  }

  Future<void> test_reports_extension_type() async {
    await assertAutoDiagnostics('''
class Test {}

extension type ${expectLint('TestId')}(int id) {}
''');
  }

  Future<void> test_reports_unnamed_extension() async {
    await assertAutoDiagnostics('''
class Test {}

${expectLint('extension')} on Test {}
''');
  }

  Future<void> test_reports_private_declaration_by_default() async {
    await assertAutoDiagnostics('''
class Test {}

class ${expectLint('_PrivateHelper')} {}
''');
  }

  Future<void> test_reports_state_class_by_default() async {
    await assertAutoDiagnostics('''
import 'flutter.dart';

class Test extends StatefulWidget {}

class ${expectLint('_TestState')} extends State<Test> {}
''');
  }

  // ---------------------------------------------------------------------------
  // allow_private Configuration
  // ---------------------------------------------------------------------------

  Future<void> test_does_not_report_private_declarations_when_allowed() async {
    _configureRule(allowPrivate: true);

    await assertNoDiagnostics(r'''
class Test {}

class _PrivateHelper {}

enum _PrivateEnum { a, b }

mixin _PrivateMixin {}

extension _PrivateExtension on String {}

// Unnamed extensions are library-private by Dart specification.
extension on String {}
''');
  }

  Future<void> test_reports_public_class_when_private_allowed() async {
    _configureRule(allowPrivate: true);

    await assertAutoDiagnostics('''
class Test {}

class _PrivateHelper {}

class ${expectLint('OtherPublic')} {}
''');
  }

  // ---------------------------------------------------------------------------
  // ignored_types Configuration
  // ---------------------------------------------------------------------------

  Future<void> test_does_not_report_on_state_when_type_ignored() async {
    _configureRule(ignoredTypes: ['State']);

    await assertNoDiagnostics(r'''
import 'flutter.dart';

class Test extends StatefulWidget {}

class _TestState extends State<Test> {}
''');
  }

  Future<void> test_reports_unrelated_class_when_type_ignored() async {
    _configureRule(ignoredTypes: ['State']);

    await assertAutoDiagnostics('''
import 'flutter.dart';

class Test extends StatefulWidget {}

class _TestState extends State<Test> {}

class ${expectLint('UnrelatedClass')} {}
''');
  }

  // ---------------------------------------------------------------------------
  // Sealed Class Hierarchy
  // ---------------------------------------------------------------------------

  Future<void> test_does_not_report_on_sealed_class_hierarchy() async {
    await assertNoDiagnostics(r'''
sealed class Result {}

class Success extends Result {
  final int value;
  Success(this.value);
}

class Failure extends Result {
  final String error;
  Failure(this.error);
}
''');
  }

  Future<void> test_does_not_report_on_sealed_class_implements() async {
    await assertNoDiagnostics(r'''
sealed class Result {}

class Success implements Result {}

class Failure implements Result {}
''');
  }

  Future<void> test_does_not_report_on_sealed_class_enum_implements() async {
    await assertNoDiagnostics(r'''
sealed class Status {}

enum ItemStatus implements Status {
  active,
  inactive,
}
''');
  }

  Future<void> test_reports_unrelated_class_in_sealed_hierarchy() async {
    await assertAutoDiagnostics('''
sealed class Result {}

class Success extends Result {}

class Failure extends Result {}

class ${expectLint('OtherClass')} {}
''');
  }

  Future<void>
  test_reports_class_extending_external_with_same_name_as_sealed() async {
    newFile('$testPackageLibPath/other.dart', r'''
class Result {}
''');

    await assertAutoDiagnostics('''
import 'other.dart' as other;

sealed class Result {}

class ${expectLint('Helper')} extends other.Result {}
''');
  }

  Future<void> test_does_not_report_on_transitive_sealed_subclass() async {
    await assertNoDiagnostics(r'''
sealed class Result {}

class Success extends Result {}

class SpecialSuccess extends Success {}
''');
  }

  // ---------------------------------------------------------------------------
  // maximum_loc Configuration
  // ---------------------------------------------------------------------------

  Future<void> test_does_not_report_when_loc_equals_maximum() async {
    _configureRule(maximumLoc: 3);

    await assertNoDiagnostics(r'''
class Test {}

class SmallHelper {
  void run() {}
}
''');
  }

  Future<void> test_does_not_report_on_loc_with_comments_and_blanks() async {
    _configureRule(maximumLoc: 3);

    await assertNoDiagnostics(r'''
class Test {}

// Comment before helper class
class SmallHelper {
  // Method comment

  void run() {}
}
''');
  }

  Future<void> test_reports_when_loc_exceeds_maximum() async {
    _configureRule(maximumLoc: 3);

    await assertAutoDiagnostics('''
class Test {}

class ${expectLint('LargeHelper')} {
  void lineOne() {}
  void lineTwo() {}
  void lineThree() {}
}
''');
  }

  Future<void> test_reports_when_loc_exceeds_maximum_with_doc_comments() async {
    _configureRule(maximumLoc: 3);

    await assertAutoDiagnostics('''
class Test {}

/// Documentation comment
/// across multiple lines
class ${expectLint('LargeHelper')} {
  void lineOne() {}
  void lineTwo() {}
  void lineThree() {}
}
''');
  }

  Future<void> test_does_not_report_on_loc_with_doc_comments() async {
    _configureRule(maximumLoc: 3);

    await assertNoDiagnostics(r'''
class Test {}

/// Documentation comment
/// across multiple lines
class SmallHelper {
  void run() {}
}
''');
  }

  Future<void> test_reports_when_loc_exceeds_maximum_with_metadata() async {
    _configureRule(maximumLoc: 3);

    await assertAutoDiagnostics('''
class Test {}

/// Documentation comment
@deprecated
class ${expectLint('LargeHelper')} {
  void lineOne() {}
  void lineTwo() {}
  void lineThree() {}
}
''');
  }

  // ---------------------------------------------------------------------------
  // exclude_entity Configuration
  // ---------------------------------------------------------------------------

  Future<void> test_does_not_report_on_excluded_entities() async {
    _configureRule(
      excludeEntity: ['enum', 'mixin', 'extension', 'extension_type'],
    );

    await assertNoDiagnostics(r'''
class Test {}

enum TestRole { admin, user }

mixin LoggingMixin {}

extension TestFormatting on Test {}

extension type TestId(int id) {}
''');
  }

  Future<void> test_reports_unrelated_class_when_entity_excluded() async {
    _configureRule(excludeEntity: ['enum']);

    await assertAutoDiagnostics('''
class Test {}

enum TestStatus { active, inactive }

class ${expectLint('OtherClass')} {}
''');
  }
}
