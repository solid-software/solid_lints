import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:solid_lints/src/lints/prefer_match_file_name/models/declaration_token_info.dart';

/// The AST visitor that will collect all Class, Enum, Extension and Mixin
/// declarations
class PreferMatchFileNameVisitor extends RecursiveAstVisitor<void> {
  final _declarations = <DeclarationTokenInfo>[];

  /// List of all declarations
  Iterable<DeclarationTokenInfo> get declarations => _declarations
    ..sort(
      // partition into public and private
      // put public ones first
      // each partition sorted by declaration order
      (a, b) => _publicDeclarationsFirst(a, b) ?? _byDeclarationOrder(a, b),
    );

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    super.visitClassDeclaration(node);

    _declarations.add((token: node.name, parent: node));
  }

  @override
  void visitExtensionDeclaration(ExtensionDeclaration node) {
    super.visitExtensionDeclaration(node);

    final name = node.name;
    if (name != null) {
      _declarations.add((token: name, parent: node));
    }
  }

  @override
  void visitMixinDeclaration(MixinDeclaration node) {
    super.visitMixinDeclaration(node);

    _declarations.add((token: node.name, parent: node));
  }

  @override
  void visitEnumDeclaration(EnumDeclaration node) {
    super.visitEnumDeclaration(node);

    _declarations.add((token: node.name, parent: node));
  }

  int? _publicDeclarationsFirst(
    DeclarationTokenInfo a,
    DeclarationTokenInfo b,
  ) {
    final isAPrivate = Identifier.isPrivateName(a.token.lexeme);
    final isBPrivate = Identifier.isPrivateName(b.token.lexeme);
    if (!isAPrivate && isBPrivate) {
      return -1;
    } else if (isAPrivate && !isBPrivate) {
      return 1;
    }
    // no reorder needed;
    return null;
  }

  int _byDeclarationOrder(DeclarationTokenInfo a, DeclarationTokenInfo b) {
    return a.token.offset.compareTo(b.token.offset);
  }
}
