import 'dart:developer';
import 'dart:io';

import 'package:solid_lints/src/utils/docs_parser/output_formatters/rules_documentation_formatter.dart';
import 'package:solid_lints/src/utils/docs_parser/parser_utils.dart';
import 'package:solid_lints/src/utils/docs_parser/parsers/rule_parser.dart';

/// DocsParser orchestration class
class DocsParser<T> {
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
  T parse(Directory dir, {bool sortRulesAlphabetically = true}) {
    final libDir = dir.parent.parent;
    final customTypes = _scanForCustomTypes(libDir);
    final templates = ParserUtils.scanForTemplates(libDir);

    final rulesDocs = _findRuleFiles(dir)
        .map((path) => RuleParser(
              rulePath: path,
              customTypes: customTypes,
              templates: templates,
            ))
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

  Map<String, String> _scanForCustomTypes(Directory libDir) {
    final customTypes = <String, String>{
      'DiagnosticSeverity': 'String',
    };

    for (final entity in libDir.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;

      try {
        final content = entity.readAsStringSync();
        if (!content.contains('@docType')) continue;

        final ast = ParserUtils.parseAst(entity.path);
        for (final declaration in ast.declarations) {
          final name = ParserUtils.getDeclarationName(declaration);
          if (name == null) continue;

          final doc = ParserUtils.formatDocumentationComment(
            declaration.documentationComment,
          );
          if (doc == null) continue;

          final match = ParserUtils.docTypeRegex.firstMatch(doc);
          final type = match?.group(1);
          if (type != null) {
            customTypes[name] = type.trim();
          }
        }
      } catch (_) {
        // Ignore parse errors on some files if any
      }
    }

    return customTypes;
  }

  List<String> _findRuleFiles(Directory dir) {
    final rulesPaths = <String>[];
    for (final entity in dir.listSync()) {
      if (entity is File) {
        if (ruleFileSuffixes.contains(ParserUtils.fileNameSuffix(entity.uri))) {
          rulesPaths.add(entity.path);
        }
      } else if (entity is Directory) {
        rulesPaths.addAll(_findRuleFiles(entity));
      }
    }

    return rulesPaths;
  }
}
