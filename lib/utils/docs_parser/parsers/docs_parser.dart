import 'dart:io';

import 'package:solid_lints/utils/docs_parser/output_formatters/rules_documentation_formatter.dart';
import 'package:solid_lints/utils/docs_parser/parsers/base_parser.dart';
import 'package:solid_lints/utils/docs_parser/parsers/rule_parser.dart';

///
class DocsParser<T> extends BaseParser {
  static const _ruleFileSuffixes = ['rule', 'metric'];

  ///
  final RulesDocumentationFormatter<T> formatter;

  ///
  const DocsParser({required this.formatter});

  ///
  T parse(Directory dir, {bool sortRulesAlphabetically = true}) {
    final rulesDocs = _findRuleFiles(dir)
        .map(RuleParser.new)
        .map((parser) => parser.parse())
        .toList(growable: false);

    if (sortRulesAlphabetically) {
      rulesDocs.sort((a, b) => a.name.compareTo(b.name));
    }

    return formatter.format(rulesDocs);
  }

  List<String> _findRuleFiles(Directory dir) {
    final rulesPaths = <String>[];
    for (final entity in dir.listSync()) {
      if (entity is File) {
        if (_ruleFileSuffixes.contains(fileNameSuffix(entity.uri))) {
          rulesPaths.add(entity.path);
        }
      } else if (entity is Directory) {
        rulesPaths.addAll(_findRuleFiles(entity));
      }
    }

    return rulesPaths;
  }
}
