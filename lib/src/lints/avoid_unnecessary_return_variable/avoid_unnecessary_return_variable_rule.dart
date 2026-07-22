import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/error/error.dart';
import 'package:solid_lints/src/lints/avoid_unnecessary_return_variable/visitors/avoid_unnecessary_return_variable_visitor.dart';

/// An `avoid_unnecessary_return_variable` rule which forbids returning
/// an immutable variable if it can be rewritten in return statement itself.
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
class AvoidUnnecessaryReturnVariableRule extends AnalysisRule {
  /// The lint rule name. Must be public to generate docs.
  static const lintName = 'avoid_unnecessary_return_variable';

  /// The message shown when the lint is triggered.
  static const String _lintMessage = """
Avoid creating unnecessary variable only for return.
Rewrite the variable evaluation into return statement instead.""";

  /// Lint code.
  static const LintCode _code = LintCode(
    lintName,
    _lintMessage,
  );

  /// Creates a new instance of [AvoidUnnecessaryReturnVariableRule]
  AvoidUnnecessaryReturnVariableRule()
    : super(
        name: lintName,
        description: _lintMessage,
      );

  @override
  LintCode get diagnosticCode => _code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final visitor = AvoidUnnecessaryReturnVariableVisitor(this);
    registry.addReturnStatement(this, visitor);
  }
}
