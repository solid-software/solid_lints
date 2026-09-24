import 'package:solid_lints/src/utils/docs_parser/models/rule_doc.dart';

/// Extracts and sanitizes concise descriptions from rule documentation.
abstract final class RuleDescriptionExtractor {
  static final _firstParagraphEndPattern = RegExp(
    r'(?:\n\s*\n|^\s*(?:#|```|[-*]\s|See more here:))',
    multiLine: true,
  );
  static final _whitespacePattern = RegExp(r'\s+');
  static final _firstSentencePattern = RegExp(
    r'^.*?\.(?:\s+(?=[A-Z])|$)',
    dotAll: true,
  );

  /// Extracts and formats a concise description from [rule] documentation.
  static String extract(RuleDoc rule) {
    final doc = rule.doc.trim();
    final end = _firstParagraphEndPattern.firstMatch(doc)?.start;
    final paragraph = (end != null ? doc.substring(0, end) : doc)
        .replaceAll(_whitespacePattern, ' ')
        .trim();

    if (paragraph.isEmpty) {
      return 'Lint rule ${rule.name} for Dart and Flutter.';
    }

    final sentence =
        _firstSentencePattern.firstMatch(paragraph)?[0]?.trim() ?? paragraph;

    return sentence.replaceAll('`', '');
  }
}
