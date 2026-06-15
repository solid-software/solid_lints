import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/error/error.dart';
import 'package:solid_lints/src/lints/avoid_unnecessary_type_casts/visitors/avoid_unnecessary_type_casts_visitor.dart';
import 'package:solid_lints/src/models/solid_lint_rule.dart';

/// An `avoid_unnecessary_type_casts` rule which
/// warns about unnecessary usage of `as` operator
class AvoidUnnecessaryTypeCastsRule extends SolidLintRule {
  /// This lint rule represents
  /// the error whether we use bad formatted double literals.
  static const lintName = 'avoid_unnecessary_type_casts';

  static const LintCode _code = LintCode(
    lintName,
    "Avoid unnecessary usage of as operator.",
  );

  @override
  LintCode get diagnosticCode => _code;

  /// Creates a new instance of [AvoidUnnecessaryTypeCastsRule]
  AvoidUnnecessaryTypeCastsRule()
    : super(
        name: lintName,
        description: _code.problemMessage,
      );

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final visitor = AvoidUnnecessaryTypeCastsVisitor(this);
    registry.addAsExpression(this, visitor);
  }
}
