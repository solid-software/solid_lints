import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:analyzer_testing/src/analysis_rule/pub_package_resolution.dart';
import 'package:collection/collection.dart';

import 'auto_lint_data.dart';

mixin AutoTestLintOffsets on AnalysisRuleTest {
  int _nextPlaceholderId = 0;
  final Map<String, AutoLintData> _placeholderToData = {};

  Future<void> assertAutoDiagnostics(String source) async {
    try {
      final placeholders = _placeholderToData.entries
          .map(
            (entry) => (
              placeholder: entry.key,
              data: entry.value,
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
          lint(
            match.index + replacedPlaceholdersDelta,
            match.data.code.length,
            correctionContains: match.data.correctionContains,
            messageContainsAll: match.data.messageContainsAll,
            name: match.data.name,
            contextMessages: match.data.contextMessages,
          ),
        );
        replacedPlaceholdersDelta +=
            match.data.code.length - match.placeholder.length;
      }

      final resolvedSource = _placeholderToData.entries.fold(
        source,
        (resolved, entry) => resolved.replaceFirst(entry.key, entry.value.code),
      );

      await assertDiagnostics(resolvedSource, expectedDiagnostics);
    } finally {
      _nextPlaceholderId = 0;
      _placeholderToData.clear();
    }
  }

  String expectLint(
    String code, {
    Pattern? correctionContains,
    List<Pattern> messageContainsAll = const [],
    String? name,
    List<ExpectedContextMessage>? contextMessages,
  }) {
    final placeholder = '__AUTO_TEST_LINT_${_nextPlaceholderId++}__';
    _placeholderToData[placeholder] = AutoLintData(
      code: code,
      correctionContains: correctionContains,
      messageContainsAll: messageContainsAll,
      name: name,
      contextMessages: contextMessages,
    );
    return placeholder;
  }
}
