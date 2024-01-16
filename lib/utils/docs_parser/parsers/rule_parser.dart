import 'dart:io';

import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:collection/collection.dart';
import 'package:solid_lints/utils/docs_parser/models/rule_doc.dart';
import 'package:solid_lints/utils/docs_parser/parser_utils.dart';
import 'package:solid_lints/utils/docs_parser/parsers/parameters_parser.dart';

///
class RuleParser {
  static const _lintNameVariable = 'lintName';

  /// Path to the rule file
  final String rulePath;

  /// [RuleParser] constructor
  const RuleParser(this.rulePath);

  ///
  RuleDoc parse() {
    final ast = parseFile(
      path: rulePath,
      featureSet: FeatureSet.latestLanguageVersion(),
    );
    final declaration =
        ast.unit.declarations.whereType<ClassDeclaration>().firstWhereOrNull(
              (declaration) =>
                  declaration.documentationComment?.childEntities.isNotEmpty ??
                  false,
            );

    if (declaration == null) {
      throw 'Rule at the path "$rulePath" does not have documentation string';
    }

    final name = _parseClassName(declaration);
    final doc = ParserUtils.formatDocumentationComment(
      declaration.documentationComment,
    );

    if (name == null || doc == null) {
      throw 'Rule at the path "$rulePath" has invalid format.';
    }

    final parameters = ParametersParser(
      ruleDirectory: File(rulePath).parent,
    ).parse();

    return RuleDoc(
      name: name,
      doc: doc,
      parameters: parameters,
    );
  }

  String? _parseClassName(ClassDeclaration classDeclaration) {
    for (final member in classDeclaration.members) {
      if (member is FieldDeclaration &&
          member.isStatic &&
          member.fields.variables.first.name.lexeme == _lintNameVariable) {
        final variableName = member.fields.variables.first.initializer;

        if (variableName is StringLiteral) {
          return variableName.stringValue;
        }
      }
    }

    return null;
  }
}
