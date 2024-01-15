import 'dart:io';

import 'package:path/path.dart';
import 'package:solid_lints/utils/docs_parser/models/rule_doc.dart';
import 'package:solid_lints/utils/docs_parser/output_formatters/markdown_formatter.dart';
import 'package:solid_lints/utils/docs_parser/parser_utils.dart';
import 'package:solid_lints/utils/docs_parser/parsers/rule_parser.dart';

void main() async {
  final dir =
      Directory(normalize(join(Directory.current.path, 'lib', 'lints')));

  final ruleFiles = ParserUtils.findRuleFiles(dir);

  final List<RuleDoc> rulesDocs = [];
  for (final rulePath in ruleFiles) {
    final ruleParser = RuleParser(rulePath);
    rulesDocs.add(ruleParser.parse());
  }

  final formatter = MarkdownFormatter(rulesDocs);
  File('out.md').writeAsStringSync(formatter.format());
}
