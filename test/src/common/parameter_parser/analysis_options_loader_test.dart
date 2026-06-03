import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/file_system/file_system.dart';
import 'package:analyzer/workspace/workspace.dart';
import 'package:analyzer_testing/src/analysis_rule/pub_package_resolution.dart';
import 'package:solid_lints/src/common/parameter_parser/analysis_options_loader.dart';
import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AnalysisOptionsLoaderTest);
  });
}

@reflectiveTest
class AnalysisOptionsLoaderTest extends PubPackageResolutionTest {
  // TODO: use actual [Rule.lintName] after migrating to analyzer_server_plugin
  // Can't be used right now because they have compile errors
  static const _mockRuleThatNeedsConfigName = 'mock_rule_that_needs_config';
  static const _mockRule2Name = 'mock_rule_2';
  static const _cyclomaticComplexityName = 'cyclomatic_complexity';

  static const _mockAnalysisOptionsContent = '''
plugins:
  solid_lints:
    diagnostics:
      $_mockRuleThatNeedsConfigName:
        abc: def
      $_mockRule2Name:
        foo: bar
        exclude:
          - class_name: MockClass
            method_name: mockMethod
      $_cyclomaticComplexityName:
        max_complexity: 10
        exclude:
          - class_name: MockClass
            method_name: mockMethod
          - method_name: mockMethod2
  ''';
  static const _mockDifferentAnalysisOptionsContent = '''
plugins:
  solid_lints:
    diagnostics:
      $_mockRuleThatNeedsConfigName:
        abc: ghi
      $_mockRule2Name:
        foo: baz
        exclude:
          - class_name: MockOtherClass
            method_name: mockOtherMethod
      $_cyclomaticComplexityName:
        max_complexity: 20
        exclude:
          - class_name: MockOtherClass
            method_name: mockOtherMethod
          - method_name: mockOtherMethod2
  ''';

  late AnalysisOptionsLoader analysisOptionsLoader;
  late RuleContext mockRuleContext;

  @override
  void setUp() {
    super.setUp();

    analysisOptionsLoader =
        AnalysisOptionsLoader(resourceProvider: resourceProvider);
    mockRuleContext = _createMockContextForPackage(testPackageRootPath);

    _writeMockAnalysisOptionsYamlFile();

    analysisOptionsLoader.loadRulesOptionsFromContext(mockRuleContext);
  }

  void _writeMockAnalysisOptionsYamlFile() {
    newAnalysisOptionsYamlFile(
      testPackageRootPath,
      _mockAnalysisOptionsContent,
    );
  }

  void test_cached_response_is_scoped_to_package_and_rule() {
    const otherPackageRootPath = '/home/other';

    newFolder(otherPackageRootPath);
    newPubspecYamlFile(otherPackageRootPath, 'name: other');
    newAnalysisOptionsYamlFile(
      otherPackageRootPath,
      _mockDifferentAnalysisOptionsContent,
    );

    for (final ruleName in [
      _mockRuleThatNeedsConfigName,
      _mockRule2Name,
      _cyclomaticComplexityName
    ]) {
      final currentPackageOptions = analysisOptionsLoader.getRuleOptions(
        mockRuleContext,
        ruleName,
      );
      final otherPackageOptions = analysisOptionsLoader.getRuleOptions(
        _createMockContextForPackage(otherPackageRootPath),
        ruleName,
      );

      expect(
        currentPackageOptions,
        isNot(equals(otherPackageOptions)),
      );
    }
  }

  void test_each_rule_gets_its_options() {
    analysisOptionsLoader.loadRulesOptionsFromContext(mockRuleContext);

    final mockRuleThatNeedsConfigOptions = analysisOptionsLoader.getRuleOptions(
      mockRuleContext,
      _mockRuleThatNeedsConfigName,
    );
    final mockRule2Options = analysisOptionsLoader.getRuleOptions(
      mockRuleContext,
      _mockRule2Name,
    );
    final cyclomaticComplexityOptions = analysisOptionsLoader.getRuleOptions(
      mockRuleContext,
      _cyclomaticComplexityName,
    );

    expect(mockRuleThatNeedsConfigOptions, isNotNull);
    expect(mockRuleThatNeedsConfigOptions, {'abc': 'def'});

    expect(mockRule2Options, isNotNull);
    expect(mockRule2Options, {
      'foo': 'bar',
      'exclude': [
        {'class_name': 'MockClass', 'method_name': 'mockMethod'},
      ]
    });

    expect(cyclomaticComplexityOptions, isNotNull);
    expect(cyclomaticComplexityOptions, {
      'max_complexity': 10,
      'exclude': [
        {'class_name': 'MockClass', 'method_name': 'mockMethod'},
        {'method_name': 'mockMethod2'},
      ]
    });
  }

  void test_invalidates_cache_when_analysis_options_changed() {
    final initialOptions = analysisOptionsLoader.getRuleOptions(
      mockRuleContext,
      _mockRuleThatNeedsConfigName,
    );

    newAnalysisOptionsYamlFile(
      testPackageRootPath,
      _mockDifferentAnalysisOptionsContent,
    );
    analysisOptionsLoader.loadRulesOptionsFromContext(mockRuleContext);

    final updatedOptions = analysisOptionsLoader.getRuleOptions(
      mockRuleContext,
      _mockRuleThatNeedsConfigName,
    );

    expect(initialOptions, {'abc': 'def'});
    expect(updatedOptions, {'abc': 'ghi'});
    expect(updatedOptions, isNot(same(initialOptions)));
  }

  void test_loads_and_parses_rule_options_from_yaml_file() {
    analysisOptionsLoader.loadRulesOptionsFromContext(mockRuleContext);

    final options = analysisOptionsLoader.getRuleOptions(
      mockRuleContext,
      _mockRuleThatNeedsConfigName,
    );

    expect(options, isNotNull);
    expect(options, {'abc': 'def'});
  }

  void test_returns_cached_response_for_same_rule_name() {
    analysisOptionsLoader.loadRulesOptionsFromContext(mockRuleContext);

    final firstOptions = analysisOptionsLoader.getRuleOptions(
      mockRuleContext,
      _mockRuleThatNeedsConfigName,
    );
    final secondOptions = analysisOptionsLoader.getRuleOptions(
      mockRuleContext,
      _mockRuleThatNeedsConfigName,
    );

    expect(secondOptions, same(firstOptions));
  }

  RuleContext _createMockContextForPackage(String packageRootPath) {
    return _TestRuleContext(
      _TestWorkspacePackage(getFolder(packageRootPath)),
    );
  }
}

class _TestRuleContext implements RuleContext {
  @override
  final WorkspacePackage? package;

  _TestRuleContext(this.package);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _TestWorkspacePackage implements WorkspacePackage {
  @override
  final Folder root;

  _TestWorkspacePackage(this.root);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
