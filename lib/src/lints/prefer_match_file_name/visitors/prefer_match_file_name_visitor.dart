import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:solid_lints/src/common/parameters/excluded_entities_list_parameter.dart';
import 'package:solid_lints/src/lints/prefer_match_file_name/models/declaration_token_info.dart';
import 'package:solid_lints/src/lints/prefer_match_file_name/prefer_match_file_name_rule.dart';
import 'package:solid_lints/src/utils/node_utils.dart';

/// The AST visitor that will collect all Class, Enum, Extension, Mixin and
/// Extension Type declarations
class PreferMatchFileNameVisitor extends SimpleAstVisitor<void> {
  /// The lint rule
  final PreferMatchFileNameRule rule;

  /// The rule context
  final RuleContext context;

  /// Iterable that contains the name of entity (or entities) that should
  /// be ignored
  final ExcludedEntitiesListParameter excludedEntities;

  /// Constructor of [PreferMatchFileNameVisitor] class
  PreferMatchFileNameVisitor(
    this.rule,
    this.context,
    this.excludedEntities,
  );

  @override
  void visitCompilationUnit(CompilationUnit node) {
    final declarations = <DeclarationTokenInfo>[];

    for (final declaration in node.declarations) {
      if (excludedEntities.shouldIgnoreEntity(declaration)) {
        continue;
      }

      final token = switch (declaration) {
        final ClassDeclaration classDecl => classDecl.namePart.typeName,
        final ExtensionDeclaration extDecl => extDecl.name,
        final MixinDeclaration mixinDecl => mixinDecl.name,
        final EnumDeclaration enumDecl => enumDecl.namePart.typeName,
        final ExtensionTypeDeclaration extTypeDecl =>
          extTypeDecl.primaryConstructor.typeName,
        _ => null,
      };

      if (token != null) {
        declarations.add((token: token, parent: declaration));
      }
    }

    if (declarations.isEmpty) return;

    declarations.sort(
      (a, b) => _publicDeclarationsFirst(a, b) ?? _byDeclarationOrder(a, b),
    );

    final firstDeclaration = declarations.first;
    final fullName = context.currentUnit?.file.path;

    if (fullName != null &&
        rule.doNormalizedNamesMatch(
          fullName,
          firstDeclaration.token.lexeme,
        )) {
      return;
    }

    final nodeType = humanReadableNodeType(
      firstDeclaration.parent,
    ).toLowerCase();

    final reporter = context.currentUnit?.diagnosticReporter;
    reporter?.atToken(
      firstDeclaration.token,
      rule.diagnosticCode,
      arguments: [nodeType],
    );
  }

  int? _publicDeclarationsFirst(
    DeclarationTokenInfo a,
    DeclarationTokenInfo b,
  ) {
    final isAPrivate = Identifier.isPrivateName(a.token.lexeme);
    final isBPrivate = Identifier.isPrivateName(b.token.lexeme);

    return switch ((isAPrivate, isBPrivate)) {
      (false, true) => -1,
      (true, false) => 1,
      _ => null,
    };
  }

  int _byDeclarationOrder(DeclarationTokenInfo a, DeclarationTokenInfo b) {
    return a.token.offset.compareTo(b.token.offset);
  }
}
