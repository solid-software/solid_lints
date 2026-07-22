import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:analyzer_testing/utilities/utilities.dart';
import 'package:solid_lints/src/common/parameter_parser/analysis_options_loader.dart';
import 'package:solid_lints/src/lints/use_descriptive_names_for_type_parameters/use_descriptive_names_for_type_parameters_rule.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../../utils/auto_test_lint_offsets.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(UseDescriptiveNamesForTypeParametersRuleTest);
  });
}

@reflectiveTest
class UseDescriptiveNamesForTypeParametersRuleTest extends AnalysisRuleTest
    with AutoTestLintOffsets {
  static const _mockAnalysisOptionsContent = '''
plugins:
  solid_lints:
    diagnostics:
      use_descriptive_names_for_type_parameters:
        min_type_parameters: 3
  ''';

  @override
  void setUp() {
    rule = UseDescriptiveNamesForTypeParametersRule(
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

  Future<void> test_reports_on_class() async {
    await assertAutoDiagnostics('''
class MyClass<
  ${expectLint('T')},
  ${expectLint('U')},
  ${expectLint('V')}
> {}
''');
  }

  Future<void> test_reports_on_class_type_alias() async {
    await assertAutoDiagnostics('''
class Base {}
mixin MyMixin {}
class MyAlias<
  ${expectLint('T')},
  ${expectLint('U')},
  ${expectLint('V')}
> = Base with MyMixin;
''');
  }

  Future<void> test_reports_on_enum() async {
    await assertAutoDiagnostics('''
enum MyEnum<
  ${expectLint('T')},
  ${expectLint('U')},
  ${expectLint('V')}
> {
  a, b
}
''');
  }

  Future<void> test_reports_on_method() async {
    await assertAutoDiagnostics('''
class MyClass {
  void myMethod<
    ${expectLint('T')},
    ${expectLint('U')},
    ${expectLint('V')}
  >() {}
}
''');
  }

  Future<void> test_reports_on_function() async {
    await assertAutoDiagnostics('''
void myFunction<
  ${expectLint('T')},
  ${expectLint('U')},
  ${expectLint('V')}
>() {}
''');
  }

  Future<void> test_reports_on_mixin() async {
    await assertAutoDiagnostics('''
mixin MyMixin<
  ${expectLint('T')},
  ${expectLint('U')},
  ${expectLint('V')}
> {}
''');
  }

  Future<void> test_reports_on_extension() async {
    await assertAutoDiagnostics('''
extension MyExtension<
  ${expectLint('T')},
  ${expectLint('U')},
  ${expectLint('V')}
> on List<T> {}
''');
  }

  Future<void> test_reports_on_generic_type_alias() async {
    await assertAutoDiagnostics('''
typedef MyAlias<
  ${expectLint('T')},
  ${expectLint('U')},
  ${expectLint('V')}
> = Map<T, U>;
''');
  }

  Future<void> test_reports_on_function_type_alias() async {
    await assertAutoDiagnostics('''
typedef void MyFuncAlias<
  ${expectLint('T')},
  ${expectLint('U')},
  ${expectLint('V')}
>(T a, U b, V c);
''');
  }

  Future<void> test_reports_on_generic_function_type() async {
    await assertAutoDiagnostics('''
void test() {
  final void Function<
    ${expectLint('T')},
    ${expectLint('U')},
    ${expectLint('V')}
  >(T, U, V) func;
}
''');
  }

  Future<void> test_reports_on_anonymous_function() async {
    await assertAutoDiagnostics('''
void test() {
  final func = <
    ${expectLint('T')},
    ${expectLint('U')},
    ${expectLint('V')}
  >(T a, U b, V c) => a;
}
''');
  }

  Future<void> test_reports_on_extension_type() async {
    await assertAutoDiagnostics('''
extension type MyExtensionType<
  ${expectLint('T')},
  ${expectLint('U')},
  ${expectLint('V')}
>(List<T> list) {}
''');
  }

  Future<void> test_does_not_report_on_descriptive_names() async {
    await assertNoDiagnostics('''
class MyClass<TSource, TResult, TError> {}
''');
  }

  Future<void> test_does_not_report_on_wildcard() async {
    await assertNoDiagnostics('''
class MyClass<TSource, TResult, _> {}
''');
  }

  Future<void> test_does_not_report_below_threshold() async {
    await assertNoDiagnostics('''
class MyClass<T, U> {}
''');
  }

  Future<void> test_reports_when_min_type_parameters_is_1() async {
    newAnalysisOptionsYamlFile(
      testPackageRootPath,
      '''${analysisOptionsContent(rules: [rule.name])}
plugins:
  solid_lints:
    diagnostics:
      use_descriptive_names_for_type_parameters:
        min_type_parameters: 1''',
    );

    await assertAutoDiagnostics('''
class MyClass<${expectLint('T')}> {}
''');
  }
}
