import 'package:solid_lints/utils/docs_parser/models/rule_doc.dart';

abstract class BaseFormatter {
  final List<RuleDoc> rules;

  const BaseFormatter(this.rules);

  String format() {
    final formattedResult = StringBuffer();
    for (final rule in rules) {
      formattedResult.writeln(formatRuleDoc(rule));
    }

    return formattedResult.toString();
  }

  String formatRuleDoc(RuleDoc rule);
}
