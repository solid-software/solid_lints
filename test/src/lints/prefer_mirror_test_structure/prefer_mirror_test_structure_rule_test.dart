import 'package:analyzer/error/error.dart';
import 'package:analyzer/src/diagnostic/diagnostic.dart' as diag;
import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:solid_lints/src/lints/prefer_mirror_test_structure/prefer_mirror_test_structure_rule.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(PreferMirrorTestStructureRuleTest);
  });
}

@reflectiveTest
class PreferMirrorTestStructureRuleTest extends AnalysisRuleTest {
  static const _stubContent = 'class AuthService {}';

  @override
  List<DiagnosticCode> get ignoredDiagnosticCodes => [
    ...super.ignoredDiagnosticCodes,
    diag.unusedImport,
  ];

  @override
  void setUp() {
    rule = PreferMirrorTestStructureRule();
    newPackage('other_package')
      ..addFile('lib/services/auth_service.dart', _stubContent);
    _newLibFile('services/auth_service.dart');
    super.setUp();
  }

  String _testPath(String relativePath) =>
      '$testPackageRootPath/test/$relativePath';

  String _libPath(String relativePath) => '$testPackageLibPath/$relativePath';

  void _newLibFile(String relativePath, [String content = _stubContent]) =>
      newFile(_libPath(relativePath), content);

  void _newTestFile(String relativePath, [String content = _stubContent]) =>
      newFile(_testPath(relativePath), content);

  Future<void> assertTestMismatch({
    required String testFile,
    required String importUri,
    required String expectedTestPath,
    String? content,
  }) => _assertTestFileDiagnostics(
    _testPath(testFile),
    content ?? "import '$importUri';\n\nvoid main() {}\n",
    targetImport: "'$importUri'",
    expectedPath: expectedTestPath,
  );

  Future<void> assertTestMatch({
    required String testFile,
    required String importUri,
    String? content,
  }) => _assertNoTestFileDiagnostics(
    _testPath(testFile),
    content ?? "import '$importUri';\n\nvoid main() {}\n",
  );

  Future<void> _assertTestFileDiagnostics(
    String path,
    String content, {
    required String targetImport,
    required String expectedPath,
  }) async {
    newFile(path, content);
    final offset = content.indexOf(targetImport);
    assert(
      offset != -1,
      'targetImport "$targetImport" was not found in content.',
    );
    await assertDiagnosticsInFile(path, [
      lint(
        offset,
        targetImport.length,
        correctionContains: "Move the test file to '$expectedPath'.",
        messageContainsAll: [
          "The test file folder structure does not mirror the 'lib/' folder "
              'structure.',
        ],
      ),
    ]);
  }

  Future<void> _assertNoTestFileDiagnostics(String path, String content) async {
    newFile(path, content);
    await assertNoDiagnosticsInFile(path);
  }

  // --- Matching structure (no diagnostics) ---

  Future<void> test_does_not_report_when_test_matches_lib_structure() =>
      assertTestMatch(
        testFile: 'services/auth_service_test.dart',
        importUri: 'package:test/services/auth_service.dart',
      );

  Future<void> test_does_not_report_when_relative_import_structure_matches() =>
      assertTestMatch(
        testFile: 'services/auth_service_test.dart',
        importUri: '../../lib/services/auth_service.dart',
      );

  Future<void> test_does_not_report_when_both_test_and_lib_are_in_root() async {
    _newLibFile('app.dart');

    await assertTestMatch(
      testFile: 'app_test.dart',
      importUri: 'package:test/app.dart',
    );
  }

  Future<void> test_does_not_report_when_deeply_nested_matches() async {
    _newLibFile('src/features/auth/services/auth_service.dart');

    await assertTestMatch(
      testFile: 'src/features/auth/services/auth_service_test.dart',
      importUri: 'package:test/src/features/auth/services/auth_service.dart',
    );
  }

  // --- Mismatched structure (diagnostics reported) ---

  Future<void> test_reports_when_test_in_root_but_lib_in_subfolder() =>
      assertTestMismatch(
        testFile: 'auth_service_test.dart',
        importUri: 'package:test/services/auth_service.dart',
        expectedTestPath: 'test/services/auth_service_test.dart',
      );

  Future<void> test_reports_when_test_is_in_different_subfolder() =>
      assertTestMismatch(
        testFile: 'features/auth_service_test.dart',
        importUri: 'package:test/services/auth_service.dart',
        expectedTestPath: 'test/services/auth_service_test.dart',
      );

  Future<void> test_reports_when_relative_import_structure_mismatches() =>
      assertTestMismatch(
        testFile: 'auth_service_test.dart',
        importUri: '../lib/services/auth_service.dart',
        expectedTestPath: 'test/services/auth_service_test.dart',
      );

  Future<void> test_reports_when_lib_in_root_but_test_in_subfolder() async {
    _newLibFile('app.dart');

    await assertTestMismatch(
      testFile: 'sub/app_test.dart',
      importUri: 'package:test/app.dart',
      expectedTestPath: 'test/app_test.dart',
    );
  }

  Future<void> test_reports_when_target_import_is_not_first() async {
    _newLibFile('services/other_service.dart');

    await assertTestMismatch(
      testFile: 'auth_service_test.dart',
      importUri: 'package:test/services/auth_service.dart',
      expectedTestPath: 'test/services/auth_service_test.dart',
      content: '''
import 'package:test/services/other_service.dart';
import 'package:test/services/auth_service.dart';

void main() {}
''',
    );
  }

  Future<void> test_reports_when_target_import_has_prefix() =>
      assertTestMismatch(
        testFile: 'auth_service_test.dart',
        importUri: 'package:test/services/auth_service.dart',
        expectedTestPath: 'test/services/auth_service_test.dart',
        content: '''
import 'package:test/services/auth_service.dart' as auth;

void main() {}
''',
      );

  Future<void> test_reports_when_deeply_nested_mismatches() async {
    _newLibFile('src/features/auth/services/auth_service.dart');

    await assertTestMismatch(
      testFile: 'features/auth_service_test.dart',
      importUri: 'package:test/src/features/auth/services/auth_service.dart',
      expectedTestPath:
          'test/src/features/auth/services/auth_service_test.dart',
    );
  }

  // --- Exclusions and edge cases (no diagnostics) ---

  Future<void> test_does_not_report_for_file_without_test_suffix() async {
    _newLibFile('services/test_helper.dart');

    await assertTestMatch(
      testFile: 'test_helper.dart',
      importUri: 'package:test/services/test_helper.dart',
    );
  }

  Future<void> test_does_not_report_when_no_matching_implementation_import() =>
      assertTestMatch(
        testFile: 'flow_test.dart',
        importUri: 'package:test/services/auth_service.dart',
      );

  Future<void> test_does_not_report_when_file_outside_test_folder() =>
      _assertNoTestFileDiagnostics(
        _libPath('services/auth_service_test.dart'),
        '''
import 'package:test/services/auth_service.dart';

void main() {}
''',
      );

  Future<void> test_does_not_report_for_external_package_import() =>
      assertTestMatch(
        testFile: 'auth_service_test.dart',
        importUri: 'package:other_package/services/auth_service.dart',
      );

  Future<void> test_does_not_report_for_relative_import_in_test() async {
    _newTestFile('helpers/auth_service.dart');

    await assertTestMatch(
      testFile: 'services/auth_service_test.dart',
      importUri: '../helpers/auth_service.dart',
    );
  }
}
