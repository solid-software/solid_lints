import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:solid_lints/lints/prefer_match_file_name/models/declaration_token_info.dart';

/// The AST visitor that will collect all Class, Enum, Extension and Mixin
/// declarations
class PreferMatchFileNameVisitor extends RecursiveAstVisitor<void> {
  final _declarations = <DeclarationTokeInfo>[];

  /// List of all declarations
  Iterable<DeclarationTokeInfo> get declarations =>
      _declarations..sort(_compareByPrivateType);

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    super.visitClassDeclaration(node);

    _declarations.add(DeclarationTokeInfo(node.name, node));
  }

  @override
  void visitExtensionDeclaration(ExtensionDeclaration node) {
    super.visitExtensionDeclaration(node);

    final name = node.name;
    if (name != null) {
      _declarations.add(DeclarationTokeInfo(name, node));
    }
  }

  @override
  void visitMixinDeclaration(MixinDeclaration node) {
    super.visitMixinDeclaration(node);

    _declarations.add(DeclarationTokeInfo(node.name, node));
  }

  @override
  void visitEnumDeclaration(EnumDeclaration node) {
    super.visitEnumDeclaration(node);

    _declarations.add(DeclarationTokeInfo(node.name, node));
  }

  int _compareByPrivateType(DeclarationTokeInfo a, DeclarationTokeInfo b) {
    final isAPrivate = Identifier.isPrivateName(a.token.lexeme);
    final isBPrivate = Identifier.isPrivateName(b.token.lexeme);
    if (!isAPrivate && isBPrivate) {
      return -1;
    } else if (isAPrivate && !isBPrivate) {
      return 1;
    }

    return a.token.offset.compareTo(b.token.offset);
  }
}
