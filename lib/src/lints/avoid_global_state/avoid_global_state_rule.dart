import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

/// Avoid top-level and static mutable variables.
///
/// Top-level variables can be modified from anywhere,
/// which leads to hard to debug applications.
///
/// Prefer using a state management solution.
///
/// ### Example
///
/// #### BAD:
///
/// ```dart
/// var globalMutable = 0; // LINT
///
/// class Test {
///   static int globalMutable = 0; // LINT
/// }
/// ```
///
/// #### GOOD:
///
/// ```dart
/// final globalFinal = 1;
/// const globalConst = 1;
///
/// class Test {
///   static const int globalConst = 1;
///   static final int globalFinal = 1;
/// }
/// ```
class AvoidGlobalStateRule extends AnalysisRule {
  /// Lint name used for suppression and reporting.
  static const String lintName = 'avoid_global_state';

  /// Lint code used for suppression and reporting.
  static const LintCode code = LintCode(
    lintName,
    'Avoid variables that can be globally mutated.',
    correctionMessage:
        'Prefer using final/const or a state management solution.',
  );

  /// Creates an instance of [AvoidGlobalStateRule].
  AvoidGlobalStateRule()
      : super(
          name: lintName,
          description:
              'Avoid top-level or static mutable variables to reduce shared mutable state.',
        );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final visitor = _Visitor(this);

    registry.addTopLevelVariableDeclaration(this, visitor);
    registry.addFieldDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AvoidGlobalStateRule rule;

  _Visitor(this.rule);

  @override
  void visitTopLevelVariableDeclaration(TopLevelVariableDeclaration node) {
    for (final variable in node.variables.variables) {
      if (_isPublicMutable(variable)) {
        rule.reportAtNode(variable);
      }
    }
  }

  @override
  void visitFieldDeclaration(FieldDeclaration node) {
    if (!node.isStatic) return;

    for (final variable in node.fields.variables) {
      if (_isPublicMutable(variable)) {
        rule.reportAtNode(variable);
      }
    }
  }

  /// Returns true if the variable is mutable and not private.
  bool _isPublicMutable(VariableDeclaration variable) {
    return _isMutable(variable) && !_isPrivate(variable);
  }

  /// A variable is mutable if it is not final or const.
  bool _isMutable(VariableDeclaration variable) {
    final element = variable.declaredFragment?.element;

    final isFinal = element?.isFinal ?? false;
    final isConst = element?.isConst ?? false;

    return !isFinal && !isConst;
  }

  /// A variable is private if its element is private.
  bool _isPrivate(VariableDeclaration variable) {
    final element = variable.declaredFragment?.element;
    return element?.isPrivate ?? false;
  }
}
