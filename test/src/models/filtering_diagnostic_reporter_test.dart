import 'package:analyzer/diagnostic/diagnostic.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer_testing/src/analysis_rule/pub_package_resolution.dart';
import 'package:solid_lints/src/models/filtering_diagnostic_reporter.dart';
import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../utils/fake_analysis_options_loader.dart';
import 'fakes/fake_source.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(FilteringDiagnosticReporterTest);
  });
}

@reflectiveTest
class FilteringDiagnosticReporterTest extends PubPackageResolutionTest {
  static const _testCode = LintCode('test_code', 'Test problem');

  late _RecordingDiagnosticListener listener;
  late DiagnosticReporter delegate;
  late Map<String, bool> excludedFiles;
  late FakeAnalysisOptionsLoader loader;
  late FilteringDiagnosticReporter reporter;

  String get mainFilePath => '$testPackageLibPath/main.dart';
  String get partFilePath => '$testPackageLibPath/part.g.dart';

  @override
  void setUp() {
    super.setUp();
    listener = _RecordingDiagnosticListener();
    delegate = DiagnosticReporter(listener, FakeSource(mainFilePath));
    excludedFiles = {};
    loader = FakeAnalysisOptionsLoader(excludedFiles: excludedFiles);
    reporter = FilteringDiagnosticReporter(delegate, loader);
  }

  Future<void> test_atNode_forwards_when_file_is_not_excluded() async {
    newFile(mainFilePath, 'int x = 1;');
    final resolved = await resolveFile(mainFilePath);
    final node = resolved.unit.declarations.first;

    excludedFiles[mainFilePath] = false;

    reporter.atNode(node, _testCode);

    expect(listener.diagnostics, hasLength(1));
    expect(listener.diagnostics.first.diagnosticCode, equals(_testCode));
  }

  Future<void> test_atNode_suppresses_when_main_file_is_excluded() async {
    newFile(mainFilePath, 'int x = 1;');
    final resolved = await resolveFile(mainFilePath);
    final node = resolved.unit.declarations.first;

    excludedFiles[mainFilePath] = true;

    reporter.atNode(node, _testCode);

    expect(listener.diagnostics, isEmpty);
  }

  Future<void>
  test_atNode_suppresses_when_part_file_is_excluded_and_main_is_not() async {
    newFile(partFilePath, '''
part of 'main.dart';
int partVar = 2;
''');
    newFile(mainFilePath, '''
part 'part.g.dart';
int mainVar = 1;
''');

    final partResolved = await resolveFile(partFilePath);
    final partNode = partResolved.unit.declarations.first;

    final mainResolved = await resolveFile(mainFilePath);
    final mainNode = mainResolved.unit.declarations.first;

    excludedFiles[mainFilePath] = false;
    excludedFiles[partFilePath] = true;

    // Node from part file should be suppressed
    reporter.atNode(partNode, _testCode);
    expect(listener.diagnostics, isEmpty);

    // Node from main file should still be reported
    reporter.atNode(mainNode, _testCode);
    expect(listener.diagnostics, hasLength(1));
    expect(listener.diagnostics.first.diagnosticCode, equals(_testCode));
  }

  Future<void> test_atOffset_forwards_when_file_is_not_excluded() async {
    excludedFiles[mainFilePath] = false;

    reporter.atOffset(offset: 0, length: 10, diagnosticCode: _testCode);

    expect(listener.diagnostics, hasLength(1));
    expect(listener.diagnostics.first.diagnosticCode, equals(_testCode));
  }

  Future<void> test_atOffset_suppresses_when_file_is_excluded() async {
    excludedFiles[mainFilePath] = true;

    reporter.atOffset(offset: 0, length: 10, diagnosticCode: _testCode);

    expect(listener.diagnostics, isEmpty);
  }

  Future<void> test_atToken_forwards_when_file_is_not_excluded() async {
    newFile(mainFilePath, 'int x = 1;');
    final resolved = await resolveFile(mainFilePath);
    final token = resolved.unit.beginToken;

    excludedFiles[mainFilePath] = false;

    reporter.atToken(token, _testCode);

    expect(listener.diagnostics, hasLength(1));
    expect(listener.diagnostics.first.diagnosticCode, equals(_testCode));
  }

  Future<void> test_atToken_suppresses_when_file_is_excluded() async {
    newFile(mainFilePath, 'int x = 1;');
    final resolved = await resolveFile(mainFilePath);
    final token = resolved.unit.beginToken;

    excludedFiles[mainFilePath] = true;

    reporter.atToken(token, _testCode);

    expect(listener.diagnostics, isEmpty);
  }
}

class _RecordingDiagnosticListener implements DiagnosticListener {
  final List<Diagnostic> diagnostics = [];

  @override
  void onDiagnostic(Diagnostic diagnostic) {
    diagnostics.add(diagnostic);
  }
}
