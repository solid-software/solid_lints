import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/error/error.dart';
import 'package:solid_lints/src/lints/avoid_global_state/avoid_global_state_rule_visitor.dart';

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
          description: 'Avoid top-level or static mutable variables ',
        );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final visitor = AvoidGlobalStateRuleVisitor(this);

    registry.addTopLevelVariableDeclaration(this, visitor);
    registry.addFieldDeclaration(this, visitor);
  }
}
