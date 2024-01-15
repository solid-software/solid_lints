import 'dart:io';

import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:solid_lints/utils/docs_parser/models/parameter_doc.dart';
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
    String? name;
    String? doc;
    List<ParameterDoc>? parameters;

    final ast = parseFile(
      path: rulePath,
      featureSet: FeatureSet.latestLanguageVersion(),
    );
    for (final declaration in ast.unit.declarations) {
      if (declaration is ClassDeclaration) {
        name = _parseClassName(declaration);
        doc = ParserUtils.formatDocumentationComment(
          declaration.documentationComment,
        );
        break;
      }
    }

    parameters = ParametersParser(
      ruleDirectory: File(rulePath).parent,
    ).parse();

    if (name != null && doc != null) {
      return RuleDoc(
        name: name,
        doc: doc,
        parameters: parameters,
      );
    } else {
      throw 'Rule at the path "$rulePath" has invalid format - '
          'neither the name or docstring are null:\n'
          'Name: $name\n'
          'Doc: $doc';
    }
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
