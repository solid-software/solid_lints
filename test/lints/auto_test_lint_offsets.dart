import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';

mixin AutoTestLintOffsets on AnalysisRuleTest {
  List<String> _expectedCodeFragments = [];

  Future<void> assertAutoDiagnostics(String source) async {
    try {
      final expectedDiagnostics = [
        for (final codeFragment in _expectedCodeFragments)
          lint(source.indexOf(codeFragment), codeFragment.length),
      ];

      await assertDiagnostics(source, expectedDiagnostics);
    } finally {
      _expectedCodeFragments = [];
    }
  }

  String expectLint(String code) {
    _expectedCodeFragments.add(code);
    return code;
  }
}
