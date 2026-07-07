import 'dart:io';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:solid_lints/src/utils/docs_parser/models/rule_doc.dart';
import 'package:solid_lints/src/utils/docs_parser/parsers/parameters_parser.dart';
import 'package:solid_lints/src/utils/docs_parser/utils/parser_utils.dart';

/// RuleParser class to parse lint rules
class RuleParser {
  /// Path to the rule file
  final String rulePath;

  /// Global map of custom types to their primitives
  final Map<String, String> customTypes;

  /// Global map of template definitions
  final Map<String, String> templates;

  /// [RuleParser] constructor
  const RuleParser({
    required this.rulePath,
    required this.customTypes,
    required this.templates,
  });

  ///
  RuleDoc parse() {
    final ast = ParserUtils.parseAst(rulePath);

    ClassDeclaration? ruleClass;
    String? name;

    for (final declaration in ast.declarations.whereType<ClassDeclaration>()) {
      final parsedName = ParserUtils.getLintName(declaration);
      if (parsedName != null) {
        ruleClass = declaration;
        name = parsedName;
        break;
      }
    }

    if (ruleClass == null || name == null) {
      throw 'Rule class with "lintName" not found in "$rulePath".';
    }

    var doc = ruleClass.documentationComment.formatted;
    if (doc == null) {
      throw 'Rule at the path "$rulePath" does not have documentation string';
    }

    doc = ParserUtils.expandMacros(doc, templates, source: rulePath);

    final parameters = ParametersParser(
      ruleDirectory: File(rulePath).parent,
      customTypes: customTypes,
    ).parse();

    return RuleDoc(
      name: name,
      doc: doc,
      parameters: parameters,
    );
  }

}
