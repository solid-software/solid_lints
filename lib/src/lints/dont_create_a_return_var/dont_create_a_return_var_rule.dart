import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element2.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:solid_lints/src/lints/dont_create_a_return_var/visitors/dont_create_a_return_var_visitor.dart';
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

    final element = expr.element;
    if (element is! LocalVariableElement2) return;
    final returnVariableElement = element;

    if (!returnVariableElement.isFinal && !returnVariableElement.isConst) {
      return;
    }

    final blockBody = statement.parent;
    if (blockBody == null) return;

    final visitor = DontCreateAReturnVarVisitor(
      returnVariableElement,
      statement,
    );
    blockBody.visitChildren(visitor);

    if (!visitor.hasBadStatementCount()) return;

    //it is 100% bad if return statement follows declaration
    if (!visitor.foundTokensBetweenDeclarationAndReturn) {
      reporter.atNode(statement, code);
      return;
    }

    final declaration = visitor.variableDeclaration;

    //check if immutable
    final initializer = declaration?.initializer;
    if (initializer == null) return;

    if (!_isExpressionImmutable(initializer)) return;

    reporter.atNode(statement, code);
  }

  bool _isExpressionImmutable(Expression expr) {
    if (expr is Literal) return true;

    if (expr case final PrefixedIdentifier prefixed) {
      return _isExpressionImmutable(prefixed.prefix) &&
          _isExpressionImmutable(prefixed.identifier);
    }

    if (expr case final BinaryExpression binExpr) {
      return _isExpressionImmutable(binExpr.leftOperand) &&
          _isExpressionImmutable(binExpr.rightOperand);
    }

    if (expr case final SimpleIdentifier identifier) {
      return _isSimpleIdentifierImmutable(identifier);
    }

    return false;
  }

  bool _isSimpleIdentifierImmutable(SimpleIdentifier identifier) {
    if (identifier.element case final VariableElement2 variable
        when variable.isFinal || variable.isConst) {
      return true;
    }

    if (identifier.element is ClassElement2) return true;

    if (identifier.element case final GetterElement getter) {
      if (getter.variable3 case final PropertyInducingElement2 property
          when property.isFinal || property.isConst) {
        return true;
      }
    }

    return false;
  }
}
