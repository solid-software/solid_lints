import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:solid_lints/utils/docs_parser/models/rule_doc.dart';
import 'package:solid_lints/utils/docs_parser/output_formatters/rules_documentation_formatter.dart';

/// Markdown output formatter
class MarkdownFormatter implements RulesDocumentationFormatter<String> {
  @override
  String format(List<RuleDoc> rules) {
    return [
      '# Solid Lints Documentation',
      '## Table of contents:',
      _formatTableOfContents(rules),
      '---',
      ...rules.map(_formatRuleToMarkdown),
    ].join('\n\n');
  }

  String _formatTableOfContents(List<RuleDoc> rules) => rules
      .mapIndexed(
          (index, rule) => '${index + 1}. [${rule.name}](#${rule.name})')
      .join('\n');

  String _formatRuleToMarkdown(RuleDoc rule) {
    final formattedString = StringBuffer();

    formattedString.writeln('## ${rule.name}');
    formattedString.writeln(rule.doc);

    if (rule.parameters.isNotEmpty) {
      formattedString.writeln('### Parameters:');

      for (final parameter in rule.parameters) {
        formattedString.writeln(
          const HtmlEscape().convert(
            '- **${parameter.name}** (_${parameter.type}_)  ',
          ),
        );
        formattedString.writeln('  ${parameter.doc}');
      }
    }

    return formattedString.toString();
  }
}
