import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:solid_lints/src/lints/proper_super_calls/proper_super_calls_rule.dart';

/// Visitor for the proper [ProperSuperCallsRule].
class ProperSuperCallsVisitor extends SimpleAstVisitor<void> {
  /// Callback to report violations.
  final void Function(Token name, {required bool isInitState}) onViolation;

  static const _initState = 'initState';
  static const _dispose = 'dispose';
  static const _override = 'override';

  /// Creates a new instance of [ProperSuperCallsVisitor].
  ProperSuperCallsVisitor({required this.onViolation});

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    final methodName = node.name.lexeme;
    final body = node.body;

    if ((methodName == _initState || methodName == _dispose) &&
        body is BlockFunctionBody) {
      final hasOverride = node.metadata.any(
        (annotation) => annotation.name.name == _override,
      );
      if (!hasOverride) return;

      final statements = body.block.statements;

      // Logic for initState: super.initState() must be the very first statement.
      if (methodName == _initState &&
          !_isSuperCallFirst(statements, _initState)) {
        onViolation(node.name, isInitState: true);
      }

      // Logic for dispose: super.dispose() must be the very last statement.
      if (methodName == _dispose && !_isSuperCallLast(statements, _dispose)) {
        onViolation(node.name, isInitState: false);
      }
    }
  }

  /// Returns true if the first statement is the expected super call.
  bool _isSuperCallFirst(List<Statement> statements, String name) {
    return statements.isNotEmpty && _isTargetSuperCall(statements.first, name);
  }

  /// Returns true if the last statement is the expected super call.
  bool _isSuperCallLast(List<Statement> statements, String name) {
    return statements.isNotEmpty && _isTargetSuperCall(statements.last, name);
  }

  /// Checks if a statement is a [MethodInvocation] on [SuperExpression].
  bool _isTargetSuperCall(Statement statement, String name) {
    if (statement is ExpressionStatement) {
      final expr = statement.expression;
      return expr is MethodInvocation &&
          expr.target is SuperExpression &&
          expr.methodName.name == name;
    }
    return false;
  }
}
