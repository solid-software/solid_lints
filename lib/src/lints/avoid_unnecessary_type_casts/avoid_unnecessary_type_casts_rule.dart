import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/error/error.dart';
import 'package:solid_lints/src/lints/avoid_unnecessary_type_casts/visitors/avoid_unnecessary_type_casts_visitor.dart';
import 'package:solid_lints/src/models/solid_lint_rule.dart';

/// An `avoid_unnecessary_type_casts` rule which
/// warns about unnecessary usage of the `as` operator.
///
/// A cast is unnecessary when the static type of the expression is already
/// compatible with the target type. Casting from a nullable type to a
/// non-nullable type is allowed, because it can change nullability.
///
/// {@template solid_lints.avoid_unnecessary_type_casts.example}
/// ### Example
///
/// #### BAD:
///
/// ```dart
/// final testList = [1.0, 2.0, 3.0];
/// final result = testList as List<double>; // LINT
///
/// final testMap = {'A': 'B'};
/// final castedMapValue = testMap['A'] as String?; // LINT
///
/// final testString = 'String';
/// _testFun(testString as String); // LINT
///
/// void fun(String a) {
///   final result = (a as String).length; // LINT
/// }
/// ```
///
/// #### GOOD:
///
/// ```dart
/// final double? nullableD = 2.0;
/// // casting `Type? as Type` is allowed
/// final castedD = nullableD as double;
///
/// final testMap = {'A': 'B'};
/// final castedNotNullMapValue = testMap['A'] as String;
/// ```
/// {@endtemplate}
class AvoidUnnecessaryTypeCastsRule extends SolidLintRule {
  /// The name of this lint rule.
  static const lintName = 'avoid_unnecessary_type_casts';

  /// Reported when the `as` operator is used on an expression whose static type
  /// is already compatible with the cast target.
  ///
  /// {@macro solid_lints.avoid_unnecessary_type_casts.example}
  static const LintCode _code = LintCode(
    lintName,
    'Avoid unnecessary usage of as operator.',
    correctionMessage: 'Remove the unnecessary type cast.',
  );

  @override
  LintCode get diagnosticCode => _code;

  /// Creates a new instance of [AvoidUnnecessaryTypeCastsRule].
  AvoidUnnecessaryTypeCastsRule()
    : super(
        name: lintName,
        description:
            'Warns about unnecessary usage of the `as` operator when the '
            'static type already satisfies the cast.',
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
