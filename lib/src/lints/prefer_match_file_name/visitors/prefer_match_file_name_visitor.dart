import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:collection/collection.dart';
import 'package:solid_lints/src/common/parameters/excluded_entities_list_parameter.dart';
import 'package:solid_lints/src/lints/prefer_match_file_name/models/declaration_token_info.dart';
import 'package:solid_lints/src/utils/file_name_matcher.dart';
import 'package:solid_lints/src/utils/iterable_utils.dart';
import 'package:solid_lints/src/utils/node_utils.dart';

/// The AST visitor that will collect all Class, Enum, Extension, Mixin and
/// Extension Type declarations
class PreferMatchFileNameVisitor extends SimpleAstVisitor<void> {
  /// The diagnostic code to report
  final DiagnosticCode diagnosticCode;

  /// The rule context
  final RuleContext context;

  /// Iterable that contains the name of entity (or entities) that should
  /// be ignored
  final ExcludedEntitiesListParameter excludedEntities;

  /// Constructor of [PreferMatchFileNameVisitor] class
  PreferMatchFileNameVisitor({
    required this.diagnosticCode,
    required this.context,
    required this.excludedEntities,
  });

  @override
  void visitCompilationUnit(CompilationUnit node) {
    final declarations = node.declarations
        .whereNot(excludedEntities.shouldIgnoreEntity)
        .map<DeclarationTokenInfo?>(
          (d) {
            final token = switch (d) {
              ClassDeclaration() => d.namePart.typeName,
              ExtensionDeclaration() => d.name,
              MixinDeclaration() => d.name,
              EnumDeclaration() => d.namePart.typeName,
              ExtensionTypeDeclaration() => d.namePart.typeName,
              _ => null,
            };

            return token == null ? null : (token: token, parent: d);
          },
        )
        .nonNulls
        .multiSortedBy(
          [
            (t) => Identifier.isPrivateName(t.token.lexeme) ? 1 : 0,
            (t) => t.token.offset,
          ],
        );

    if (declarations.isEmpty) return;

    final firstDeclaration = declarations.first;
    final fullName = context.currentUnit?.file.path;

    if (FileNameMatcher.matches(
      filePath: fullName,
      identifierName: firstDeclaration.token.lexeme,
    )) {
      return;
    }

    final nodeType = humanReadableNodeType(
      firstDeclaration.parent,
    ).toLowerCase();

    final reporter = context.currentUnit?.diagnosticReporter;
    reporter?.atToken(
      firstDeclaration.token,
      diagnosticCode,
      arguments: [nodeType],
    );
  }
}
