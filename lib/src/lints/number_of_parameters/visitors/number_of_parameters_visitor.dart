import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:solid_lints/src/lints/number_of_parameters/models/number_of_parameters_parameters.dart';
import 'package:solid_lints/src/lints/number_of_parameters/number_of_parameters_rule.dart';
import 'package:solid_lints/src/utils/node_utils.dart';

/// A visitor that checks the number of parameters for functions and methods.
class NumberOfParametersVisitor extends SimpleAstVisitor<void> {
  final NumberOfParametersRule _rule;
  final NumberOfParametersParameters _parameters;

  /// Creates a new instance of [NumberOfParametersVisitor].
  NumberOfParametersVisitor(this._rule, this._parameters);

  void _check(Declaration node, FormalParameterList? parameterList) {
    if (parameterList == null) return;

    final isIgnored = _parameters.exclude.shouldIgnore(node);
    if (isIgnored) return;

    final count = parameterList.parameters.length;
    if (count > _parameters.maxParameters) {
      _rule.reportAtNode(
        parameterList,
        arguments: [_parameters.maxParameters.toString()],
      );
    }
  }

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    _check(node, node.functionExpression.parameters);
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    if (isOverride(node.metadata)) return;
    _check(node, node.parameters);
  }
}
