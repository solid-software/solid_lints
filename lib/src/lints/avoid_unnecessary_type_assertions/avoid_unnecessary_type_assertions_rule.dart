import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/error/error.dart';
import 'package:solid_lints/src/lints/avoid_unnecessary_type_assertions/fixes/avoid_unnecessary_type_assertions_fix.dart';
import 'package:solid_lints/src/lints/avoid_unnecessary_type_assertions/visitors/unnecessary_is_expression_visitor.dart';
import 'package:solid_lints/src/lints/avoid_unnecessary_type_assertions/visitors/unnecessary_where_type_visitor.dart';
import 'package:solid_lints/src/models/rule_with_fixes.dart';

/// Warns about unnecessary usage of `is` and `whereType` operators.
///
/// ### Example:
/// {@macro solid_lints.avoid_unnecessary_type_assertions.example_is}
/// {@macro solid_lints.avoid_unnecessary_type_assertions.example_where}
class AvoidUnnecessaryTypeAssertionsRule extends AnalysisRule
    implements RuleWithFixes {
  /// The name of 'is' operator
  static const operatorIsName = 'is';

  /// The name of 'whereType' method
  static const whereTypeMethodName = 'whereType';

  /// This lint rule represents
  /// the error whether we use bad formatted double literals.
  static const lintName = 'avoid_unnecessary_type_assertions';

  static const _unnecessaryTypeAssertionsCode = LintCode(
    lintName,
    "Unnecessary usage of the {0}.",
  );

  /// Creates a new instance of [AvoidUnnecessaryTypeAssertionsRule]
  AvoidUnnecessaryTypeAssertionsRule()
    : super(
        name: lintName,
        description: "Unnecessary usage of typecast operators.",
      );

  @override
  DiagnosticCode get diagnosticCode => _unnecessaryTypeAssertionsCode;

  @override
  Iterable<MapEntry<DiagnosticCode, ProducerGenerator>> get fixesForCodes =>
      const [
        MapEntry(
          _unnecessaryTypeAssertionsCode,
          AvoidUnnecessaryTypeAssertionsFix.new,
        ),
      ];

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    super.registerNodeProcessors(registry, context);

    final unnecessaryIsExpressionVisitor = UnnecessaryIsExpressionVisitor(this);
    registry.addIsExpression(this, unnecessaryIsExpressionVisitor);

    final unnecessaryWhereTypeVisitor = UnnecessaryWhereTypeVisitor(this);
    registry.addMethodInvocation(this, unnecessaryWhereTypeVisitor);
  }
}
