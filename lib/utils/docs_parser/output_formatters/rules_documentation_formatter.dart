import 'package:solid_lints/utils/docs_parser/models/rule_doc.dart';

/// Documentation formatter interface
abstract class RulesDocumentationFormatter<T> {
  /// Get the formatted lints documentation
  T format(List<RuleDoc> rules);
}
