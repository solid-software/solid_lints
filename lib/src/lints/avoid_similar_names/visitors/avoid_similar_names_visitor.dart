import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:solid_lints/src/lints/avoid_similar_names/avoid_similar_names_rule.dart';
import 'package:solid_lints/src/lints/avoid_similar_names/models/scope_variable.dart';
import 'package:solid_lints/src/lints/avoid_similar_names/utils/name_tokenizer.dart';
import 'package:solid_lints/src/lints/avoid_similar_names/visitors/local_variables_visitor.dart';

/// A visitor that checks for variables with
/// confusingly similar names.
class AvoidSimilarNamesVisitor extends RecursiveAstVisitor<void> {
  final AvoidSimilarNamesRule _rule;
  final _reportedNodes = <AstNode>{};

  /// Creates a new instance of
  /// [AvoidSimilarNamesVisitor].
  AvoidSimilarNamesVisitor(this._rule);

  @override
  void visitMethodDeclaration(
    MethodDeclaration node,
  ) {
    super.visitMethodDeclaration(node);
    _checkScope(node.parameters, node.body);
  }

  @override
  void visitConstructorDeclaration(
    ConstructorDeclaration node,
  ) {
    super.visitConstructorDeclaration(node);
    _checkScope(node.parameters, node.body);
  }

  @override
  void visitFunctionDeclaration(
    FunctionDeclaration node,
  ) {
    super.visitFunctionDeclaration(node);
    _checkScope(
      node.functionExpression.parameters,
      node.functionExpression.body,
    );
  }

  void _checkScope(
    FormalParameterList? parameters,
    FunctionBody body,
  ) {
    final variables = <ScopeVariable>[];

    variables.addAll(_extractParameters(parameters));

    final collector = LocalVariablesVisitor();
    body.accept(collector);
    variables.addAll(collector.variables);

    _compareVariables(variables);
  }

  Iterable<ScopeVariable> _extractParameters(
    FormalParameterList? parameters,
  ) => [
    for (final parameter in parameters?.parameters ?? const <FormalParameter>[])
      if (parameter.name case final nameToken?)
        if (ScopeVariable.createOrNull(
              nameToken: nameToken,
              type: parameter.declaredFragment?.element.type,
              node: parameter,
            )
            case final variable?)
          variable,
  ];

  void _compareVariables(
    List<ScopeVariable> variables,
  ) {
    for (var i = 0; i < variables.length; i++) {
      for (var j = i + 1; j < variables.length; j++) {
        _comparePair(variables[i], variables[j]);
      }
    }
  }

  void _comparePair(
    ScopeVariable a,
    ScopeVariable b,
  ) {
    if (a.type != null && b.type != null && a.type != b.type) {
      return;
    }

    switch ((a.tokens.length - b.tokens.length).abs()) {
      case 0:
        _checkSameLengthTokens(a, b);
      case 1:
        _checkDifferentLengthTokens(a, b);
    }
  }

  void _checkSameLengthTokens(
    ScopeVariable a,
    ScopeVariable b,
  ) {
    var diffCount = 0;
    var diffIndex = -1;
    for (var k = 0; k < a.tokens.length; k++) {
      if (a.tokens[k] != b.tokens[k]) {
        diffCount++;
        diffIndex = k;
      }
    }

    if (diffCount != 1) return;

    if (NameTokenizer.isNonDescriptiveToken(a.tokens[diffIndex]) &&
        NameTokenizer.isNonDescriptiveToken(b.tokens[diffIndex])) {
      _report(a, b);
    }
  }

  void _checkDifferentLengthTokens(
    ScopeVariable a,
    ScopeVariable b,
  ) {
    final (longer, shorter) = a.tokens.length > b.tokens.length
        ? (a.tokens, b.tokens)
        : (b.tokens, a.tokens);

    if (NameTokenizer.isSubsetWithNonDescriptiveToken(
      longer,
      shorter,
    )) {
      _report(a, b);
    }
  }

  void _report(ScopeVariable a, ScopeVariable b) {
    if (_reportedNodes.add(a.node)) {
      _rule.reportAtToken(a.nameToken);
    }
    if (_reportedNodes.add(b.node)) {
      _rule.reportAtToken(b.nameToken);
    }
  }
}
