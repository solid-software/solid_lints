import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:analyzer_testing/src/analysis_rule/pub_package_resolution.dart';
import 'package:collection/collection.dart';

mixin AutoTestLintOffsets on AnalysisRuleTest {
  int _nextPlaceholderId = 0;
  final Map<String, String> _placeholderToCode = {};

  Future<void> assertAutoDiagnostics(String source) async {
    try {
      final placeholders = _placeholderToCode.entries
          .map(
            (entry) => (
              placeholder: entry.key,
              code: entry.value,
              index: source.indexOf(entry.key),
            ),
          )
          .sorted((a, b) => a.index.compareTo(b.index));

      final expectedDiagnostics = <ExpectedDiagnostic>[];
      int replacedPlaceholdersDelta = 0;

      for (final match in placeholders) {
        if (match.index == -1) {
          throw StateError(
            'Expected lint placeholder "${match.placeholder}" was not found in source.',
          );
        }

        expectedDiagnostics.add(
          lint(match.index + replacedPlaceholdersDelta, match.code.length),
        );
        replacedPlaceholdersDelta +=
            match.code.length - match.placeholder.length;
      }

      final resolvedSource = _placeholderToCode.entries.fold(
        source,
        (resolved, entry) => resolved.replaceFirst(entry.key, entry.value),
      );

      await assertDiagnostics(resolvedSource, expectedDiagnostics);
    } finally {
      _nextPlaceholderId = 0;
      _placeholderToCode.clear();
    }
  }

  String expectLint(String code) {
    final placeholder = '__AUTO_TEST_LINT_${_nextPlaceholderId++}__';
    _placeholderToCode[placeholder] = code;
    return placeholder;
  }
}
