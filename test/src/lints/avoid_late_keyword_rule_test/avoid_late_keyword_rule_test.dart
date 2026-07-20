import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:analyzer_testing/utilities/utilities.dart';
import 'package:solid_lints/src/common/parameter_parser/analysis_options_loader.dart';
import 'package:solid_lints/src/lints/avoid_late_keyword/avoid_late_keyword_rule.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../../utils/auto_test_lint_offsets.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AvoidLateKeywordRuleTest);
    defineReflectiveTests(AvoidLateKeywordNoGenericsTest);
    defineReflectiveTests(AvoidLateKeywordWithGenericsTest);
  });
}

@reflectiveTest
class AvoidLateKeywordRuleTest extends AnalysisRuleTest
    with AutoTestLintOffsets {
  final String _typesDefinitions = '''
abstract class Animation {}

class AnimationController implements Animation {}

class SubAnimationController extends AnimationController {}

class ColorTween {}
''';

  @override
  void setUp() {
    rule = AvoidLateKeywordRule(
      analysisOptionsLoader: AnalysisOptionsLoader(
        resourceProvider: resourceProvider,
      ),
    );
    super.setUp();

    newAnalysisOptionsYamlFile(testPackageRootPath, '''
${analysisOptionsContent(rules: [rule.name])}
plugins:
  solid_lints:
    diagnostics:
      ${rule.name}:
        allow_initialized: false
        ignored_types:
          - Animation
''');
  }

  Future<void> test_does_not_report_ignored_types_fields() async {
    await assertNoDiagnostics('''
class Test {
  late final Animation animation1;
  late final animation2 = AnimationController();
  late final animation3 = SubAnimationController();
  late final AnimationController controller1;
}
$_typesDefinitions
    ''');
  }

  Future<void> test_does_not_report_ignored_types_local_variables() async {
    await assertNoDiagnostics('''
void test() {
  late final Animation animation1;
  late final animation2 = AnimationController();
  late final animation3 = SubAnimationController();
  late final AnimationController controller1;
}
$_typesDefinitions
    ''');
  }

  Future<void> test_reports_non_ignored_types_fields() async {
    await assertAutoDiagnostics('''
class Test {
  late final ColorTween ${expectLint('colorTween1')};
  late final ${expectLint('colorTween2 = ColorTween()')};
  late final ${expectLint('colorTween3 = colorTween2')};
  late final ${expectLint('field1 = \'string\'')};
  late final String ${expectLint('field2')};
  late final String ${expectLint('field3 = \'string\'')};
  late final ${expectLint('field4')};
}
$_typesDefinitions
    ''');
  }

  Future<void> test_reports_non_ignored_types_local_variables() async {
    await assertAutoDiagnostics('''
void test() {
  late final ColorTween ${expectLint('colorTween1')};
  late final ${expectLint('colorTween2 = ColorTween()')};
  late final ${expectLint('colorTween3 = colorTween2')};
  late final ${expectLint('local1 = \'string\'')};
  late final String ${expectLint('local2')};
  late final String ${expectLint('local4 = \'string\'')};
  late final ${expectLint('local3')};
}
$_typesDefinitions
    ''');
  }
}

@reflectiveTest
class AvoidLateKeywordNoGenericsTest extends AnalysisRuleTest
    with AutoTestLintOffsets {
  final String _typesDefinitions = '''
class Subscription<T> {}

class ConcreteTypeWithNoGenerics {}

class NotAllowed {}
''';

  @override
  void setUp() {
    rule = AvoidLateKeywordRule(
      analysisOptionsLoader: AnalysisOptionsLoader(
        resourceProvider: resourceProvider,
      ),
    );
    super.setUp();

    newAnalysisOptionsYamlFile(testPackageRootPath, '''
${analysisOptionsContent(rules: [rule.name])}
plugins:
  solid_lints:
    diagnostics:
      ${rule.name}:
        allow_initialized: false
        ignored_types:
          - Subscription
''');
  }

  Future<void> test_does_not_report_ignored_types_fields() async {
    await assertNoDiagnostics('''
class Test {
  late final Subscription subscription1;
  late final Subscription<ConcreteTypeWithNoGenerics> subscription2;
  late final Subscription<List<int>> subscription3;
  late final Subscription<List<List<int>>> subscription4;
  late final Subscription<Map<dynamic, String>> subscription5;
}
$_typesDefinitions
    ''');
  }

  Future<void> test_does_not_report_ignored_types_local_variables() async {
    await assertNoDiagnostics('''
void test() {
  late final Subscription subscription1;
  late final Subscription<ConcreteTypeWithNoGenerics> subscription2;
  late final Subscription<List<int>> subscription3;
  late final Subscription<List<List<int>>> subscription4;
  late final Subscription<Map<dynamic, String>> subscription5;
}
$_typesDefinitions
    ''');
  }

  Future<void> test_reports_non_ignored_types_fields() async {
    await assertAutoDiagnostics('''
class Test {
  late final NotAllowed ${expectLint('na1')};
}
$_typesDefinitions
    ''');
  }

  Future<void> test_reports_non_ignored_types_local_variables() async {
    await assertAutoDiagnostics('''
void test() {
  late final NotAllowed ${expectLint('na1')};
}
$_typesDefinitions
    ''');
  }
}

@reflectiveTest
class AvoidLateKeywordWithGenericsTest extends AnalysisRuleTest
    with AutoTestLintOffsets {
  final String _typesDefinitions = '''
class ColorTween {}

class AnimationController {}

class SubAnimationController extends AnimationController {}

class Allowed {}

class NotAllowed {}

class Subscription<T> {}

class ConcreteTypeWithNoGenerics {}
''';

  @override
  void setUp() {
    rule = AvoidLateKeywordRule(
      analysisOptionsLoader: AnalysisOptionsLoader(
        resourceProvider: resourceProvider,
      ),
    );
    super.setUp();

    newAnalysisOptionsYamlFile(testPackageRootPath, '''
${analysisOptionsContent(rules: [rule.name])}
plugins:
  solid_lints:
    diagnostics:
      ${rule.name}:
        allow_initialized: true
        ignored_types:
          - ColorTween
          - AnimationController
          - Subscription<List<Object?>>
          - Subscription<Map<dynamic, String>>
          - Subscription<ConcreteTypeWithNoGenerics>
''');
  }

  Future<void> test_does_not_report_ignored_types_fields() async {
    await assertNoDiagnostics('''
class Test {
  late final ColorTween colorTween;
  late final AnimationController controller1;
  late final SubAnimationController controller2;
  late final controller3 = AnimationController();
  late final controller4 = SubAnimationController();
  late final Subscription<ConcreteTypeWithNoGenerics> subscription2;
  late final Subscription<List<String>> subscription3;
  late final Subscription<List<List<int>>> subscription4;
  late final Subscription<Map<dynamic, String>> subscription5;
  late final Subscription<Map<String, String>> subscription6;
  late final field1 = 'string';
  late final a = Allowed();
}
$_typesDefinitions
    ''');
  }

  Future<void> test_does_not_report_ignored_types_local_variables() async {
    await assertNoDiagnostics('''
void test() {
  late final ColorTween colorTween;
  late final AnimationController controller1;
  late final SubAnimationController controller2;
  late final controller3 = AnimationController();
  late final controller4 = SubAnimationController();
  late final Subscription<ConcreteTypeWithNoGenerics> subscription2;
  late final Subscription<List<String>> subscription3;
  late final local1 = 'string';
  late final a = Allowed();
}
$_typesDefinitions
    ''');
  }

  Future<void> test_reports_non_ignored_types_fields() async {
    await assertAutoDiagnostics('''
class Test {
  late final String ${expectLint('field2')};
  late final ${expectLint('field3')};
  late final NotAllowed ${expectLint('na1')};
  late final Subscription<String> ${expectLint('subscription1')};
  late final Subscription<Map<String, dynamic>> ${expectLint('subscription7')};
}
$_typesDefinitions
    ''');
  }

  Future<void> test_reports_non_ignored_types_local_variables() async {
    await assertAutoDiagnostics('''
void test() {
  late final String ${expectLint('local2')};
  late final ${expectLint('local3')};
  late final NotAllowed ${expectLint('na1')};
  late final Subscription<String> ${expectLint('subscription1')};
}
$_typesDefinitions
    ''');
  }
}
