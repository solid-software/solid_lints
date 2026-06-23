import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:analyzer_testing/utilities/utilities.dart';
import 'package:solid_lints/src/common/parameter_parser/analysis_options_loader.dart';
import 'package:solid_lints/src/lints/named_parameters_ordering/named_parameters_ordering_rule.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../../../lints/auto_test_lint_offsets.dart';

void main() {
  defineRefSuite();
}

void defineRefSuite() {
  defineReflectiveSuite(() {
    defineReflectiveTests(NamedParametersOrderingRuleTest);
  });
}

@reflectiveTest
class NamedParametersOrderingRuleTest extends AnalysisRuleTest
    with AutoTestLintOffsets {
  static const _customAnalysisOptionsContent = '''
plugins:
  solid_lints:
    diagnostics:
      named_parameters_ordering:
        order:
          - required
          - required_super
          - default
          - nullable
          - super
''';

  @override
  void setUp() {
    rule = NamedParametersOrderingRule(
      analysisOptionsLoader: AnalysisOptionsLoader(
        resourceProvider: resourceProvider,
      ),
    );
    super.setUp();
    newAnalysisOptionsYamlFile(
      testPackageRootPath,
      analysisOptionsContent(rules: [rule.name]),
    );
  }

  @override
  String get analysisRule => NamedParametersOrderingRule.lintName;

  Future<void> test_does_not_report_correct_constructor_ordering() async {
    await assertNoDiagnostics(r'''
class Base {
  final String accountType;
  final String? userId;

  Base({
    required this.accountType,
    this.userId,
  });
}

class User extends Base {
  final String name;
  final String email;
  final String? age;
  final String? country;
  final bool isActive;

  User({
    required super.accountType,
    super.userId,
    required this.name,
    required this.email,
    this.age,
    this.country,
    this.isActive = true,
  });
}
''');
  }

  Future<void> test_reports_incorrect_constructor_ordering() async {
    await assertAutoDiagnostics('''
class User {
  final String accountType;
  final String? userId;

  User({
    this.userId,
    ${expectLint('required this.accountType')},
  });
}
''');
  }

  Future<void> test_reports_incorrect_constructor_ordering_complex() async {
    await assertAutoDiagnostics('''
class Base {
  final String accountType;
  final String? userId;

  Base({
    required this.accountType,
    this.userId,
  });
}

class User extends Base {
  final String name;
  final String email;
  final String? age;
  final bool isActive;

  User({
    required super.accountType,
    this.age,
    ${expectLint('super.userId')},
    required this.name,
    this.isActive = true,
    ${expectLint('required this.email')},
  });
}
''');
  }

  Future<void> test_does_not_report_correct_method_ordering() async {
    await assertNoDiagnostics(r'''
class UserProfile {
  void orderedMethod({
    required String name,
    required String email,
    int? age,
    bool isActive = true,
  }) {
    return;
  }
}
''');
  }

  Future<void> test_reports_incorrect_method_ordering() async {
    await assertAutoDiagnostics('''
class UserProfile {
  void partiallyOrderedMethod({
    required String name,
    int? age,
    ${expectLint('required String email')},
    bool isActive = true,
  }) {
    return;
  }
}
''');
  }

  Future<void> test_reports_incorrect_function_ordering() async {
    await assertAutoDiagnostics('''
void functionExample({
  required String name,
  bool isActive = true,
  ${expectLint('int? age')},
  ${expectLint('required String email')},
}) {
  return;
}
''');
  }

  Future<void> test_reports_mixed_positional_and_named_parameters() async {
    await assertAutoDiagnostics('''
void mixedParameters(
  String accountType,
  String? userId, {
  int? age,
  ${expectLint('required String email')},
  bool isActive = true,
  ${expectLint('required String name')},
}) {
  return;
}
''');
  }

  Future<void> test_reports_incorrect_ordering_with_custom_config() async {
    newAnalysisOptionsYamlFile(testPackageRootPath, '''
${analysisOptionsContent(rules: [rule.name])}
$_customAnalysisOptionsContent''');
    await assertAutoDiagnostics('''
class User {
  final String accountType;
  final String? userId;

  User({
    this.userId,
    ${expectLint('required this.accountType')},
  });
}
''');
  }

  Future<void>
  test_reports_incorrect_ordering_with_custom_config_super() async {
    newAnalysisOptionsYamlFile(testPackageRootPath, '''
${analysisOptionsContent(rules: [rule.name])}
$_customAnalysisOptionsContent''');
    await assertAutoDiagnostics('''
class Base {
  final String? name;
  Base({this.name});
}

class User extends Base {
  final String? email;
  User({
    super.name,
    ${expectLint('required this.email')},
  });
}
''');
  }

  Future<void> test_reports_incorrect_ordering_with_callback_parameter() async {
    await assertAutoDiagnostics('''
void example({
  int? age,
  ${expectLint('required void Function() onTap')},
}) {
  return;
}
''');
  }

  Future<void> test_does_not_report_correct_ordering_with_callback() async {
    await assertNoDiagnostics(r'''
void example({
  required void Function() onTap,
  int? age,
}) {
  return;
}
''');
  }

  Future<void> test_reports_incorrect_ordering_with_comments() async {
    await assertAutoDiagnostics('''
void example({
  /* Whether active */
  bool isActive = true,
  // Email comment
  ${expectLint('required String email')},
  /// The age of the user.
  /// Can be null if unknown.
  int? age,
}) {
  return;
}
''');
  }

  Future<void> test_reports_incorrect_ordering_with_complex_defaults() async {
    await assertAutoDiagnostics('''
void example({
  List<String> items = const [],
  int count = 1 + 2,
  ${expectLint('required String name')},
}) {
  return;
}
''');
  }
}
