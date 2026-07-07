import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:solid_lints/src/lints/use_descriptive_names_for_type_parameters/models/use_descriptive_names_for_type_parameters_parameters.dart';
import 'package:solid_lints/src/lints/use_descriptive_names_for_type_parameters/use_descriptive_names_for_type_parameters_rule.dart';

/// A visitor that checks descriptive names for type parameters on declarations.
class UseDescriptiveNamesForTypeParametersVisitor
    extends SimpleAstVisitor<void> {
  final UseDescriptiveNamesForTypeParametersRule _rule;
  final UseDescriptiveNamesForTypeParametersParameters _parameters;

  /// Creates a new instance of [UseDescriptiveNamesForTypeParametersVisitor].
  UseDescriptiveNamesForTypeParametersVisitor(this._rule, this._parameters);

  void _checkAndReport(TypeParameterList? typeParameters) {
    if (typeParameters == null ||
        typeParameters.typeParameters.length < _parameters.minTypeParameters) {
      return;
    }

    for (final param in typeParameters.typeParameters) {
      final name = param.name.lexeme;
      if (name.length == 1 && name != '_') {
        _rule.reportAtNode(
          param,
          arguments: [_parameters.minTypeParameters.toString()],
        );
      }
    }
  }

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    _checkAndReport(node.namePart.typeParameters);
  }

  @override
  void visitEnumDeclaration(EnumDeclaration node) {
    _checkAndReport(node.namePart.typeParameters);
  }

  @override
  void visitFunctionExpression(FunctionExpression node) {
    _checkAndReport(node.typeParameters);
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    _checkAndReport(node.typeParameters);
  }

  @override
  void visitGenericTypeAlias(GenericTypeAlias node) {
    _checkAndReport(node.typeParameters);
  }

  @override
  void visitFunctionTypeAlias(FunctionTypeAlias node) {
    _checkAndReport(node.typeParameters);
  }

  @override
  void visitGenericFunctionType(GenericFunctionType node) {
    _checkAndReport(node.typeParameters);
  }

  @override
  void visitExtensionDeclaration(ExtensionDeclaration node) {
    _checkAndReport(node.typeParameters);
  }

  @override
  void visitMixinDeclaration(MixinDeclaration node) {
    _checkAndReport(node.typeParameters);
  }

  @override
  void visitExtensionTypeDeclaration(ExtensionTypeDeclaration node) {
    _checkAndReport(node.primaryConstructor.typeParameters);
  }
}
