import 'dart:io';

import 'package:path/path.dart';
import 'package:solid_lints/utils/docs_parser/output_formatters/markdown_formatter.dart';
import 'package:solid_lints/utils/docs_parser/parser_utils.dart';
import 'package:solid_lints/utils/docs_parser/parsers/rule_parser.dart';

void main() async {
  final dir =
      Directory(normalize(join(Directory.current.path, 'lib', 'lints')));

  final ruleFiles = ParserUtils.findRuleFiles(dir);
  final rulesDocs = ruleFiles
      .map(RuleParser.new)
      .map((parser) => parser.parse())
      .toList(growable: false);

  final formatter = MarkdownFormatter();
  File('DOCUMENTATION.md').writeAsStringSync(formatter.format(rulesDocs));
}
