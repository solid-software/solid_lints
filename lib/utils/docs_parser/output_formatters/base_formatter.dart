import 'package:solid_lints/utils/docs_parser/models/rule_doc.dart';

/// Base class for output formatter
abstract class BaseFormatter {
  /// List of rules to format
  final List<RuleDoc> rules;

  ///
  const BaseFormatter(this.rules);

  /// Get formatted string containing documentation of given [rules]
  String format() {
    final formattedResult = StringBuffer();
    for (final rule in rules) {
      formattedResult.writeln(formatRuleDoc(rule));
    }

    return formattedResult.toString();
  }

  /// Get formatted string for the single given [rule]
  String formatRuleDoc(RuleDoc rule);
}
