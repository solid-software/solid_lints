import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/error/error.dart';
import 'package:solid_lints/src/lints/avoid_unrelated_type_assertions/visitors/avoid_unrelated_type_assertions_visitor.dart';

/// A `avoid_unrelated_type_assertions` rule which
/// warns about unnecessary usage of `as` operator
class AvoidUnrelatedTypeAssertionsRule extends AnalysisRule {
  /// Lint name used for suppression and reporting
  static const String lintName = 'avoid_unrelated_type_assertions';

  /// Lint description used for suppression and reporting
  static const String lintDescription =
      'Avoid unrelated "is" assertions. The result is always "{0}".';

  /// Lint code used for suppression and reporting
  static const LintCode _code = LintCode(
    lintName,
    lintDescription,
  );

  /// Creates an instance of [AvoidUnrelatedTypeAssertionsRule]
  AvoidUnrelatedTypeAssertionsRule()
      : super(name: lintName, description: lintDescription);

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

  // @override
  // void run(
  //   CustomLintResolver resolver,
  //   DiagnosticReporter reporter,
  //   CustomLintContext context,
  // ) {
  //   context.registry.addIsExpression((node) {
  //     final visitor = AvoidUnrelatedTypeAssertionsVisitor();
  //     visitor.visitIsExpression(node);

  //     for (final element in visitor.expressions.entries) {
  //       reporter.atNode(
  //         element.key,
  //         code,
  //         arguments: [element.value.toString()],
  //       );
  //     }
  //   });
  // }
}
