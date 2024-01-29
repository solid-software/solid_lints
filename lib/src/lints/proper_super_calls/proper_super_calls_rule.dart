import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:solid_lints/src/models/rule_config.dart';
import 'package:solid_lints/src/models/solid_lint_rule.dart';

/// Ensures that `super` calls are made in the correct order for the following
/// StatefulWidget methods:
///
/// - `initState`
/// - `dispose`
///
/// ### Example
///
/// #### BAD:
///
/// ```dart
/// @override
/// void initState() {
///   print('');
///   super.initState(); // LINT, super.initState should be called first.
/// }
///
/// @override
/// void dispose() {
///   super.dispose(); // LINT, super.dispose should be called last.
///   print('');
/// }
/// ```
///
/// #### GOOD:
///
/// ```dart
/// @override
/// void initState() {
///   super.initState(); // OK
///   print('');
/// }
///
/// @override
/// void dispose() {
///   print('');
///   super.dispose(); // OK
/// }
/// ```
class ProperSuperCallsRule extends SolidLintRule {
  /// The [LintCode] of this lint rule that represents
  /// the error whether the initState and dispose methods
  /// are called in the incorrect order
  static const lintName = 'proper_super_calls';
  static const _initState = 'initState';
  static const _dispose = 'dispose';
  static const _override = 'override';

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

        if (methodName == _initState || methodName == _dispose) {
          final statements = (node.body as BlockFunctionBody).block.statements;

          _checkSuperCalls(
            node,
            methodName,
            statements,
            reporter,
          );
        }
      },
    );
  }

  /// This method report an error whether `super.initState()`
  /// or `super.dispose()` are called incorrect
  void _checkSuperCalls(
    MethodDeclaration node,
    String methodName,
    List<Statement> statements,
    ErrorReporter reporter,
  ) {
    final hasOverrideAnnotation =
        node.metadata.any((annotation) => annotation.name.name == _override);

    if (!hasOverrideAnnotation) return;
    if (methodName == _initState && !_isSuperInitStateCalledFirst(statements)) {
      reporter.reportErrorForNode(
        _superInitStateCode,
        node,
      );
    }
    if (methodName == _dispose && !_isSuperDisposeCalledLast(statements)) {
      reporter.reportErrorForNode(
        _superDisposeCode,
        node,
      );
    }
  }

  /// Returns `true` if `super.initState()` is called before other code in the
  /// `initState` method, `false` otherwise.
  bool _isSuperInitStateCalledFirst(List<Statement> statements) {
    if (statements.isEmpty) return false;
    final firstStatement = statements.first;

    if (firstStatement is ExpressionStatement) {
      final expression = firstStatement.expression;

      final isSuperInitStateCalledFirst = expression is MethodInvocation &&
          expression.target is SuperExpression &&
          expression.methodName.toString() == _initState;

      return isSuperInitStateCalledFirst;
    }

    return false;
  }

  /// Returns `true` if `super.dispose()` is called at the end of the `dispose`
  /// method, `false` otherwise.
  bool _isSuperDisposeCalledLast(List<Statement> statements) {
    if (statements.isEmpty) return false;
    final lastStatement = statements.last;

    if (lastStatement is ExpressionStatement) {
      final expression = lastStatement.expression;

      final lastStatementIsSuperDispose = expression is MethodInvocation &&
          expression.target is SuperExpression &&
          expression.methodName.toString() == _dispose;

      return lastStatementIsSuperDispose;
    }

    return false;
  }
}
