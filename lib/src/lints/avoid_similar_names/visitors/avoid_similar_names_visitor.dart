import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:collection/collection.dart';
import 'package:solid_lints/src/lints/avoid_similar_names/avoid_similar_names_rule.dart';
import 'package:solid_lints/src/lints/avoid_similar_names/models/scope_variable.dart';
import 'package:solid_lints/src/lints/avoid_similar_names/utils/name_tokenizer.dart';
import 'package:solid_lints/src/lints/avoid_similar_names/visitors/local_variables_visitor.dart';
import 'package:solid_lints/src/utils/iterable_utils.dart';
import 'package:solid_lints/src/utils/types_utils.dart';

/// A visitor that checks for variables with
/// confusingly similar names.
class AvoidSimilarNamesVisitor extends SimpleAstVisitor<void> {
  final AvoidSimilarNamesRule _rule;
  final _reportedNodes = <AstNode>{};
  final _collector = LocalVariablesVisitor();

  /// Creates a new instance of
  /// [AvoidSimilarNamesVisitor].
  AvoidSimilarNamesVisitor(this._rule);

  @override
  void visitMethodDeclaration(
    MethodDeclaration node,
  ) {
    _checkScope(node.parameters, node.body);
  }

  @override
  void visitConstructorDeclaration(
    ConstructorDeclaration node,
  ) {
    _checkScope(node.parameters, node.body);
  }

  @override
  void visitFunctionDeclaration(
    FunctionDeclaration node,
  ) {
    _checkScope(
      node.functionExpression.parameters,
      node.functionExpression.body,
    );
  }

  void _checkScope(
    FormalParameterList? parameters,
    FunctionBody body,
  ) {
    _reportedNodes.clear();
    _collector.variables.clear();
    body.accept(_collector);

    final variables = [
      ..._extractParameters(parameters),
      ..._collector.variables,
    ];

    _compareVariables(variables);
    _reportedNodes.clear();
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

  void _comparePair(ScopeVariable a, ScopeVariable b) =>
      a.type?.isDifferentIgnoringNullability(b.type) ?? false
      ? null
      : switch ((a.tokens.length - b.tokens.length).abs()) {
          0 => _checkSameLengthTokens(a, b),
          1 => _checkSingleTokenLengthDifference(a, b),
          _ => null,
        };

  void _checkSameLengthTokens(
    ScopeVariable a,
    ScopeVariable b,
  ) {
    final diff = a.tokens
        .zipWithIndexed(b.tokens)
        .where((e) => e.$2 != e.$3)
        .singleOrNull;

    if (diff != null &&
        NameTokenizer.isNonDescriptiveToken(a.tokens[diff.$1]) &&
        NameTokenizer.isNonDescriptiveToken(b.tokens[diff.$1])) {
      _report(a, b);
    }
  }

  void _checkSingleTokenLengthDifference(
    ScopeVariable a,
    ScopeVariable b,
  ) {
    final [shorter, longer] = [a.tokens, b.tokens].sortedBy((e) => e.length);

    if (NameTokenizer.isSubsetWithNonDescriptiveToken(
      longer,
      shorter,
    )) {
      _report(a, b);
    }
  }

  void _report(ScopeVariable a, ScopeVariable b) => [a, b]
      .where((e) => _reportedNodes.add(e.node))
      .forEach((e) => _rule.reportAtToken(e.nameToken));
}
