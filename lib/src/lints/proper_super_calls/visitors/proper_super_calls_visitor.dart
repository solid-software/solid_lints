import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:solid_lints/src/lints/proper_super_calls/proper_super_calls_rule.dart';

/// Visitor for [ProperSuperCallsRule].
class ProperSuperCallsVisitor extends SimpleAstVisitor<void> {
  /// The rule associated with this visitor.
  final ProperSuperCallsRule rule;

  /// The context associated with this visitor.
  final RuleContext context;

  static const _initState = 'initState';
  static const _dispose = 'dispose';
  static const _flutterStateClass = 'State';

  /// Creates a new instance of [ProperSuperCallsVisitor].
  ProperSuperCallsVisitor({
    required this.rule,
    required this.context,
  });

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    final methodName = node.name.lexeme;
    final body = node.body;

    if ((methodName != _initState && methodName != _dispose) ||
        body is! BlockFunctionBody) {
      return;
    }

    if (!_overridesFlutterStateMethod(node)) {
      return;
    }

    final statements = body.block.statements;
    final reporter = context.currentUnit?.diagnosticReporter;

    if (reporter == null) return;

    if (methodName == _initState &&
        !_isSuperCallFirst(statements, _initState)) {
      reporter.atToken(
        node.name,
        ProperSuperCallsRule.superInitStateCode,
      );
    }

    if (methodName == _dispose && !_isSuperCallLast(statements, _dispose)) {
      reporter.atToken(
        node.name,
        ProperSuperCallsRule.superDisposeCode,
      );
    }
  }

  bool _overridesFlutterStateMethod(MethodDeclaration node) {
    final classElement = node.declaredFragment?.element.enclosingElement;

    if (classElement is! ClassElement) {
      return false;
    }

    final methodName = node.name.lexeme;

    final supertype = classElement.supertype;

    if (supertype == null) {
      return false;
    }

    final isStateSubclass = _isStateSubclass(supertype);

    if (!isStateSubclass) {
      return false;
    }

    return methodName == _initState || methodName == _dispose;
  }

  bool _isStateSubclass(InterfaceType supertype) {
    final isStateSubclass = supertype.element.name == _flutterStateClass ||
        supertype.allSupertypes.any(
          (t) => t.element.name == _flutterStateClass,
        );
    return isStateSubclass;
  }

  bool _isSuperCallFirst(List<Statement> statements, String name) {
    return statements.isNotEmpty && _isTargetSuperCall(statements.first, name);
  }

  bool _isSuperCallLast(List<Statement> statements, String name) {
    return statements.isNotEmpty && _isTargetSuperCall(statements.last, name);
  }

  bool _isTargetSuperCall(Statement statement, String name) {
    if (statement is! ExpressionStatement) {
      return false;
    }

    var expression = statement.expression.unParenthesized;
    if (expression is AwaitExpression) {
      expression = expression.expression.unParenthesized;
    }

    return expression is MethodInvocation &&
        expression.target is SuperExpression &&
        expression.methodName.name == name;
  }
}
