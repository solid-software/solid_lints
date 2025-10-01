import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/syntactic_entity.dart';
import 'package:analyzer/error/listener.dart';
import 'package:collection/collection.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:solid_lints/src/models/rule_config.dart';
import 'package:solid_lints/src/models/solid_lint_rule.dart';

/// A `dont_create_a_return_var` rule which forbids returning an immutable
/// variable if it can be rewritten in return statement itself.
///
/// See more here: https://github.com/solid-software/solid_lints/issues/92
///
/// ### Example
///
/// #### BAD:
/// 
/// ```dart
/// void x() {
///   final y = 1;
/// 
///   return y;
/// }
/// ```
/// 
/// #### GOOD:
/// 
/// ```dart
/// void x() {
///   return 1;
/// }
/// ```
///
class DontCreateAReturnVarRule extends SolidLintRule {
  /// This lint rule represents the error
  /// when unnecessary return variable statement is found
  static const lintName = 'dont_create_a_return_var';
  
  DontCreateAReturnVarRule._(super.config);

  /// Creates a new instance of [DontCreateAReturnVarRule]
  /// based on the lint configuration.
  factory DontCreateAReturnVarRule.createRule(CustomLintConfigs configs) {
    final rule = RuleConfig(
      configs: configs,
      name: lintName,
      problemMessage: (_) => """
Avoid creating unnecessary variable only for return.
Rewrite the variable evaluation into return statement instead.""",
    );

    return DontCreateAReturnVarRule._(rule);
  }


  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addReturnStatement(
      (statement) {
        _checkReturnStatement(
          statement: statement,
          reporter: reporter,
          context: context,
        );
      },
    );
  }

  void _checkReturnStatement({
    required ReturnStatement statement,
    required ErrorReporter reporter,
    required CustomLintContext context,
  }) {
    final expr = statement.expression;
    if (expr is! SimpleIdentifier) return;
    final returnVariableToken = expr.token;

    //Looking for statement previous to return
    final parent = statement.parent;
    if (parent == null) return;

    SyntacticEntity? previous;
    for (final child in parent.childEntities) {
      if (child == statement) break;
      previous = child;
    }
    if (previous == null) return;

    if (previous is! VariableDeclarationStatement) return;
    final declarationStatement = previous;
    
    //Checking if return variable was declared in previous statement
    final VariableDeclaration? variableDeclaration = 
      declarationStatement.variables.variables
      .firstWhereOrNull(
        (v) => v.name.toString() == returnVariableToken.toString(),
      );
    if (variableDeclaration == null) return;

    //Skipping mutable variables
    if (!variableDeclaration.isFinal && !variableDeclaration.isConst) return;

    reporter.atNode(expr, code);
  }
  
}
