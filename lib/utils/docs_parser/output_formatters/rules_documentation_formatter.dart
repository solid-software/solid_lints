import 'package:solid_lints/utils/docs_parser/models/rule_doc.dart';

///
abstract interface class RulesDocumentationFormatter<T> {
  ///
  T format(List<RuleDoc> docs);
}
