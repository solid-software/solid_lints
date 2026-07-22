import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:solid_lints/src/lints/use_descriptive_names_for_type_parameters/models/use_descriptive_names_for_type_parameters_parameters.dart';
import 'package:solid_lints/src/lints/use_descriptive_names_for_type_parameters/use_descriptive_names_for_type_parameters_rule.dart';

/// A visitor that checks descriptive names for type parameters on declarations.
class UseDescriptiveNamesForTypeParametersVisitor
    extends SimpleAstVisitor<void> {
  final UseDescriptiveNamesForTypeParametersRule _rule;
  final UseDescriptiveNamesForTypeParametersParameters _parameters;

  int get _minParameters => _parameters.minTypeParameters;

  /// Creates a new instance of [UseDescriptiveNamesForTypeParametersVisitor].
  UseDescriptiveNamesForTypeParametersVisitor(this._rule, this._parameters);

  void _visit(TypeParameterList? types) {
    if (types case TypeParameterList(
      typeParameters: final ps,
    ) when ps.length >= _minParameters) {
      ps.where(_hasInvalidShortName).forEach(_report);
    }
  }

  bool _hasInvalidShortName(TypeParameter p) =>
      p.name.length == 1 && p.name.lexeme != '_';

  void _report(TypeParameter p) =>
      _rule.reportAtNode(p, arguments: ['$_minParameters']);

  @override
  void visitClassDeclaration(ClassDeclaration node) =>
      _visit(node.namePart.typeParameters);

  @override
  void visitClassTypeAlias(ClassTypeAlias node) => _visit(node.typeParameters);

  @override
  void visitEnumDeclaration(EnumDeclaration node) =>
      _visit(node.namePart.typeParameters);

  @override
  void visitFunctionExpression(FunctionExpression node) =>
      _visit(node.typeParameters);

  @override
  void visitMethodDeclaration(MethodDeclaration node) =>
      _visit(node.typeParameters);

  @override
  void visitGenericTypeAlias(GenericTypeAlias node) =>
      _visit(node.typeParameters);

  @override
  void visitFunctionTypeAlias(FunctionTypeAlias node) =>
      _visit(node.typeParameters);

  @override
  void visitGenericFunctionType(GenericFunctionType node) =>
      _visit(node.typeParameters);

  @override
  void visitExtensionDeclaration(ExtensionDeclaration node) =>
      _visit(node.typeParameters);

  @override
  void visitMixinDeclaration(MixinDeclaration node) =>
      _visit(node.typeParameters);

  @override
  void visitExtensionTypeDeclaration(ExtensionTypeDeclaration node) =>
      _visit(node.primaryConstructor.typeParameters);
}
