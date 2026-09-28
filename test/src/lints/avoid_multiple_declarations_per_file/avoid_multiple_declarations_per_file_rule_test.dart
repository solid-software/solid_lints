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
  }

  void _configureOptions(String customOptions) {
    newAnalysisOptionsYamlFile(testPackageRootPath, '''
${analysisOptionsContent(rules: [rule.name])}
$customOptions''');
  }

  void test_singleClass_noLint() async {
    await assertNoDiagnostics(r'''
class Test {}
''');
  }

  void test_singleEnum_noLint() async {
    await assertNoDiagnostics(r'''
enum SingleEnum { a, b }
''');
  }

  void test_singleMixin_noLint() async {
    await assertNoDiagnostics(r'''
mixin SingleMixin {}
''');
  }

  void test_singleExtension_noLint() async {
    await assertNoDiagnostics(r'''
extension SingleExtension on String {}
''');
  }

  void test_multipleClasses_reportsSecondaryClass() async {
    await assertAutoDiagnostics('''
class Test {}

class ${expectLint('SecondClass')} {}
''');
  }

  void test_classAndEnum_reportsEnumByDefault() async {
    await assertAutoDiagnostics('''
class Test {}

enum ${expectLint('TestRole')} { admin, user }
''');
  }

  void test_classAndEnum_excludeEntity_noLint() async {
    _configureOptions('''
plugins:
  solid_lints:
    diagnostics:
      avoid_multiple_declarations_per_file:
        exclude_entity:
          - enum
''');

    await assertNoDiagnostics(r'''
class Test {}

enum TestRole { admin, user }
''');
  }

  void test_classAndEnum_ignoredTypesEnum_noLint() async {
    _configureOptions('''
plugins:
  solid_lints:
    diagnostics:
      avoid_multiple_declarations_per_file:
        ignored_types:
          - Enum
''');

    await assertNoDiagnostics(r'''
class Test {}

enum TestRole { admin, user }
''');
  }

  void test_classAndMixin_reportsMixin() async {
    await assertAutoDiagnostics('''
class Test {}

mixin ${expectLint('LoggingMixin')} {}
''');
  }

  void test_classAndExtension_reportsExtension() async {
    await assertAutoDiagnostics('''
class Test {}

extension ${expectLint('TestFormatting')} on Test {}
''');
  }

  void test_classAndExtensionType_reportsExtensionType() async {
    await assertAutoDiagnostics('''
class Test {}

extension type ${expectLint('TestId')}(int id) {}
''');
  }

  void test_classAndUnnamedExtension_reportsExtension() async {
    await assertAutoDiagnostics('''
class Test {}

${expectLint('extension')} on Test {}
''');
  }

  void test_allowPrivate_permitsPrivateDeclarations() async {
    _configureOptions('''
plugins:
  solid_lints:
    diagnostics:
      avoid_multiple_declarations_per_file:
        allow_private: true
''');

    await assertNoDiagnostics(r'''
class Test {}

class _PrivateHelper {}

enum _PrivateEnum { a, b }

mixin _PrivateMixin {}

extension _PrivateExtension on String {}

extension on String {}
''');
  }

  void test_allowPrivateFalse_reportsPrivateDeclaration() async {
    await assertAutoDiagnostics('''
class Test {}

class ${expectLint('_PrivateHelper')} {}
''');
  }

  void test_statefulWidgetAndState_reportsByDefault() async {
    newFile('$testPackageLibPath/flutter.dart', r'''
abstract class StatefulWidget {}

abstract class State<T extends StatefulWidget> {}
''');

    await assertAutoDiagnostics('''
import 'flutter.dart';

class Test extends StatefulWidget {}

class ${expectLint('_TestState')} extends State<Test> {}
''');
  }

  void test_statefulWidgetAndState_ignoredTypesConfigured_noLint() async {
    newFile('$testPackageLibPath/flutter.dart', r'''
abstract class StatefulWidget {}

abstract class State<T extends StatefulWidget> {}
''');

    _configureOptions('''
plugins:
  solid_lints:
    diagnostics:
      avoid_multiple_declarations_per_file:
        ignored_types:
          - State
''');

    await assertNoDiagnostics(r'''
import 'flutter.dart';

class Test extends StatefulWidget {}

class _TestState extends State<Test> {}
''');
  }

  void test_sealedClassHierarchy_noLint() async {
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

  void test_sealedClassHierarchyWithUnrelatedClass_reportsUnrelated() async {
    await assertAutoDiagnostics('''
sealed class Result {}

class Success extends Result {}

class Failure extends Result {}

class ${expectLint('OtherClass')} {}
''');
  }

  void test_maximumLoc_permitsSmallDeclarations() async {
    _configureOptions('''
plugins:
  solid_lints:
    diagnostics:
      avoid_multiple_declarations_per_file:
        maximum_loc: 4
''');

    await assertNoDiagnostics(r'''
class Test {
  void doSomething() {
    print('main');
  }
}

class SmallHelper {
  void run() {}
}
''');
  }

  void test_maximumLoc_reportsExceedingDeclarations() async {
    _configureOptions('''
plugins:
  solid_lints:
    diagnostics:
      avoid_multiple_declarations_per_file:
        maximum_loc: 3
''');

    await assertAutoDiagnostics('''
class Test {}

class ${expectLint('LargeHelper')} {
  void lineOne() {}
  void lineTwo() {}
  void lineThree() {}
}
''');
  }

  void test_typedefAndFunctions_areNotCountedAsViolations() async {
    await assertNoDiagnostics(r'''
typedef JsonMap = Map<String, Object?>;

class Test {}

void topLevelHelper() {}

const timeoutSeconds = 30;
''');
  }

  void test_excludeEntity_ignoresSpecifiedEntities() async {
    _configureOptions('''
plugins:
  solid_lints:
    diagnostics:
      avoid_multiple_declarations_per_file:
        exclude_entity:
          - mixin
          - extension
''');

    await assertNoDiagnostics(r'''
class Test {}

mixin ServiceHelper {}

extension ServiceExt on Test {}
''');
  }

  void test_classAndExtensionType_excludeEntity_noLint() async {
    _configureOptions('''
plugins:
  solid_lints:
    diagnostics:
      avoid_multiple_declarations_per_file:
        exclude_entity:
          - extension_type
''');

    await assertNoDiagnostics(r'''
class Test {}

extension type TestId(int id) {}
''');
  }

  void test_excludeEntity_extensionTypeAndEnum_noLint() async {
    _configureOptions('''
plugins:
  solid_lints:
    diagnostics:
      avoid_multiple_declarations_per_file:
        exclude_entity:
          - extension_type
          - enum
''');

    await assertNoDiagnostics(r'''
class Test {}

extension type TestId(int id) {}

enum TestStatus { active, inactive }
''');
  }
}
