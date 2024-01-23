import 'dart:developer';
import 'dart:io';

import 'package:solid_lints/utils/docs_parser/output_formatters/rules_documentation_formatter.dart';
import 'package:solid_lints/utils/docs_parser/parsers/base_parser.dart';
import 'package:solid_lints/utils/docs_parser/parsers/rule_parser.dart';

///
class DocsParser<T> extends BaseParser {
  ///
  final List<String> ruleFileSuffixes;

  ///
  final RulesDocumentationFormatter<T> formatter;

  ///
  const DocsParser({
    required this.formatter,
    required this.ruleFileSuffixes,
  });

  ///
  T parse(Directory dir, {required bool sortRulesAlphabetically}) {
    final rulesDocs = _findRuleFiles(dir)
        .map(RuleParser.new)
        .map((parser) => parser.parse())
        .toList(growable: false);

    if (rulesDocs.isEmpty) {
      throw 'Found no rules in specified directory';
    }
    log('Parsed ${rulesDocs.length} rules');

    if (sortRulesAlphabetically) {
      rulesDocs.sort((a, b) => a.name.compareTo(b.name));
    }

    return formatter.format(rulesDocs);
  }

  List<String> _findRuleFiles(Directory dir) {
    final rulesPaths = <String>[];
    for (final entity in dir.listSync()) {
      if (entity is File) {
        if (ruleFileSuffixes.contains(fileNameSuffix(entity.uri))) {
          rulesPaths.add(entity.path);
        }
      } else if (entity is Directory) {
        rulesPaths.addAll(_findRuleFiles(entity));
      }
    }

    return rulesPaths;
  }
}
