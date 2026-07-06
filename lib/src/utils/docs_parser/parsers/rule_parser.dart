import 'dart:io';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:collection/collection.dart';
import 'package:solid_lints/src/utils/docs_parser/models/rule_doc.dart';
import 'package:solid_lints/src/utils/docs_parser/parser_utils.dart';
import 'package:solid_lints/src/utils/docs_parser/parsers/parameters_parser.dart';

/// RuleParser class to parse lint rules
class RuleParser {
  static const _lintNameVariable = 'lintName';

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
    final declaration =
        ast.declarations.whereType<ClassDeclaration>().firstWhereOrNull(
              (declaration) => declaration.documentationComment != null,
            );

    if (declaration == null) {
      throw 'Rule at the path "$rulePath" does not have documentation string';
    }

    final name = _parseClassName(declaration);
    var doc = ParserUtils.formatDocumentationComment(
      declaration.documentationComment,
    );

    if (name == null || doc == null) {
      throw 'Rule at the path "$rulePath" has invalid format.';
    }

    doc = ParserUtils.expandMacros(doc, templates);

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

  String? _parseClassName(ClassDeclaration classDeclaration) {
    for (final member in ParserUtils.getClassMembers(classDeclaration)) {
      if (member is! FieldDeclaration || !member.isStatic) continue;

      final variable = member.fields.variables.firstWhereOrNull(
        (v) => v.name.lexeme == _lintNameVariable,
      );
      final initializer = variable?.initializer;

      if (initializer is StringLiteral) {
        return initializer.stringValue;
      }
    }

    return null;
  }
}
