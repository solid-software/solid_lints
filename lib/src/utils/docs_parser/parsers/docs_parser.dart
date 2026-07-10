import 'dart:developer';
import 'dart:io';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:solid_lints/src/utils/docs_parser/output_formatters/rules_documentation_formatter.dart';
import 'package:solid_lints/src/utils/docs_parser/parsers/rule_parser.dart';
import 'package:solid_lints/src/utils/docs_parser/utils/parser_extensions.dart';
import 'package:solid_lints/src/utils/docs_parser/utils/parser_utils.dart';

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
    final files = dir
        .listSync(recursive: true)
        .whereType<File>()
        .where(
          (f) => ruleFileSuffixes.contains(ParserUtils.fileNameSuffix(f.uri)),
        )
        .map((file) => file.path)
        .toList();

    if (files.isEmpty) throw 'Found no rules in specified directory';

    final libDir = ParserUtils.findLibDir(dir);

    final customTypes = {
      'DiagnosticSeverity': 'String',
      for (final entity in libDir.listSync(recursive: true))
        if (entity case File(hasDocStrings: true, :final declarations?))
          for (final declaration in declarations)
            if (declaration case CompilationUnitMember(
              :final name?,
              :final type?,
            ))
              name: type.trim(),
    };

    final templates = ParserUtils.scanForTemplates(libDir);

    final docs = [
      for (final path in files)
        RuleParser(
          rulePath: path,
          customTypes: customTypes,
          templates: templates,
        ).parse(),
    ];

    log('Parsed ${docs.length} rules');

    if (sortRulesAlphabetically) {
      docs.sort((a, b) => a.name.compareTo(b.name));
    }

    return formatter.format(docs);
  }
}
