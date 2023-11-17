import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:solid_lints/models/rule_config.dart';
import 'package:solid_lints/models/solid_lint_rule.dart';

/// Checks that `super` calls in the initState and
/// dispose methods are called in the correct order.

class ProperSuperCallsRule extends SolidLintRule {
  /// The [LintCode] of this lint rule that represents
  /// the error whether the initState and dispose methods
  /// are called in the incorrect order
  static const lintName = 'proper_super_calls';

  /// The [LintCode] of this lint rule that represents
  /// the error whether super.initState() should be called first
  static const _superInitStateCode = LintCode(
    name: lintName,
    problemMessage: "super.initState() should be first",
  );

  /// The [LintCode] of this lint rule that represents
  /// the error whether super.dispose() should be called last
  static const _superDisposeCode = LintCode(
    name: lintName,
    problemMessage: "super.dispose() should be last",
  );

  ProperSuperCallsRule._(super.config);

  /// Creates a new instance of [ProperSuperCallsRule]
  /// based on the lint configuration.
  factory ProperSuperCallsRule.createRule(CustomLintConfigs configs) {
    final rule = RuleConfig(
      name: lintName,
      configs: configs,
      problemMessage: (_) => 'Proper super calls issue',
    );

    return ProperSuperCallsRule._(rule);
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addMethodDeclaration(
      (node) {
        final methodName = node.name.toString();

        if (methodName == 'initState' || methodName == 'dispose') {
          final statements = (node.body as BlockFunctionBody).block.statements;
          
          checkSuperCalls(node, methodName, statements, reporter);
        }
      },
    );
  }

  /// This method report an error whether `super.initState()` 
  /// or `super.dispose()` are called incorrect
  void checkSuperCalls(
    MethodDeclaration node,
    String methodName,
    List<Statement> statements,
    ErrorReporter reporter,
  ) {
    if (methodName == 'initState' && !isSuperInitStateCalledFirst(statements)) {
      reporter.reportErrorForNode(
        _superInitStateCode,
        node,
      );
    }
    if (methodName == 'dispose' && !isSuperDisposeCalledLast(statements)) {
      reporter.reportErrorForNode(
        _superDisposeCode,
        node,
      );
    }
  }

  /// Returns `true` if `super.initState()` is called before other code in the
  /// `initState` method, `false` otherwise.
  bool isSuperInitStateCalledFirst(List<Statement> statements) {
    if (statements.isEmpty) return false;
    final firstStatement = statements[0];

    if (firstStatement is ExpressionStatement) {
      final expression = firstStatement.expression;

      final isSuperInitStateCalledFirst = expression is MethodInvocation &&
          expression.target is SuperExpression &&
          expression.methodName.toString() == 'initState';

      if (isSuperInitStateCalledFirst) return true;
    }

    return false;
  }

  /// Returns `true` if `super.dispose()` is called at the end of the `dispose`
  /// method, `false` otherwise.
  bool isSuperDisposeCalledLast(List<Statement> statements) {
    if (statements.isEmpty) return false;
    final lastStatement = statements[statements.length - 1];

    if (lastStatement is ExpressionStatement) {
      final expression = lastStatement.expression;

      final isSuperDisposeCalledLast = expression is MethodInvocation &&
          expression.target is SuperExpression &&
          expression.methodName.toString() == 'dispose';

      if (isSuperDisposeCalledLast) return true;
    }

    return false;
  }
}
