import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

/// AST Visitor which finds type parameters with single-letter names
/// in declarations with three or more type parameters.
class UseDescriptiveNamesForTypeParametersVisitor
    extends RecursiveAstVisitor<void> {
  /// List of type parameters with single-letter names.
  final singleLetterTypeParameters = <TypeParameter>[];

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    super.visitClassDeclaration(node);
    _checkTypeParameters(node.typeParameters);
  }

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    super.visitFunctionDeclaration(node);
    final function = node.functionExpression;
    _checkTypeParameters(function.typeParameters);
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    super.visitMethodDeclaration(node);
    _checkTypeParameters(node.typeParameters);
  }

  @override
  void visitGenericTypeAlias(GenericTypeAlias node) {
    super.visitGenericTypeAlias(node);
    _checkTypeParameters(node.typeParameters);
  }

  @override
  void visitExtensionDeclaration(ExtensionDeclaration node) {
    super.visitExtensionDeclaration(node);
    _checkTypeParameters(node.typeParameters);
  }

  @override
  void visitMixinDeclaration(MixinDeclaration node) {
    super.visitMixinDeclaration(node);
    _checkTypeParameters(node.typeParameters);
  }

  void _checkTypeParameters(TypeParameterList? typeParameters) {
    if (typeParameters == null || typeParameters.typeParameters.length < 3) {
      return;
    }

    for (final param in typeParameters.typeParameters) {
      final name = param.name.lexeme;
      if (name.length == 1) {
        singleLetterTypeParameters.add(param);
      }
    }
  }
}
