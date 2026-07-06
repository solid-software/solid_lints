import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/error/error.dart';
import 'package:solid_lints/src/lints/avoid_unrelated_type_assertions/visitors/avoid_unrelated_type_assertions_visitor.dart';

/// A `avoid_unrelated_type_assertions` rule which
/// warns about unnecessary usage of `as` operator
class AvoidUnrelatedTypeAssertionsRule extends AnalysisRule {
  /// The lint rule name. Must be public to generate docs.
  static const lintName = 'avoid_unrelated_type_assertions';

  /// The message shown when the lint rule is triggered.
  static const _lintMessage =
      'Avoid unrelated "is" assertion. The result is always "{0}".';

  /// Lint code for this rule.
  static const LintCode _code = LintCode(
    lintName,
    _lintMessage,
  );

  /// Creates a new instance of [AvoidUnrelatedTypeAssertionsRule].
  AvoidUnrelatedTypeAssertionsRule()
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
    final visitor = AvoidUnrelatedTypeAssertionsVisitor(this);
    registry.addIsExpression(this, visitor);
  }
}
