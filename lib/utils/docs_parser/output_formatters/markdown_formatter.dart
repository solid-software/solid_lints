import 'dart:convert';

import 'package:solid_lints/utils/docs_parser/models/rule_doc.dart';
import 'package:solid_lints/utils/docs_parser/output_formatters/base_formatter.dart';

class MarkdownFormatter extends BaseFormatter {
  const MarkdownFormatter(super.rules);

  @override
  String formatRuleDoc(RuleDoc rule) {
    const htmlEscape = HtmlEscape();
    final formattedString = StringBuffer();

    formattedString.writeln('### ${rule.name}');
    formattedString.writeln(rule.doc);

    if (rule.parameters.isNotEmpty) {
      formattedString.writeln('#### Parameters:');

      for (final parameter in rule.parameters) {
        formattedString.writeln(
          htmlEscape.convert('- *${parameter.name}* (_${parameter.type}_)'),
        );
        formattedString.writeln('  ${parameter.doc}');
      }
    }
    formattedString.writeln();

    return formattedString.toString();
  }
}
