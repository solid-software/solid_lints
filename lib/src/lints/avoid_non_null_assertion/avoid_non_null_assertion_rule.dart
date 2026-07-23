import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/error/error.dart';
import 'package:solid_lints/src/lints/avoid_non_null_assertion/models/avoid_non_null_assertion_parameters.dart';
import 'package:solid_lints/src/lints/avoid_non_null_assertion/visitors/avoid_non_null_assertion_visitor.dart';
import 'package:solid_lints/src/models/solid_lint_rule.dart';

/// Rule which warns about usages of bang operator ("!")
/// as it may result in unexpected runtime exceptions.
///
/// "Bang" operator with Maps is allowed, as [Dart docs](https://dart.dev/null-safety/understanding-null-safety#the-map-index-operator-is-nullable)
/// recommend using it for accessing Map values that are known to be present.
///
/// ### Example config:
///
/// ```yaml
/// plugins:
///   solid_lints:
///     diagnostics:
///       avoid_non_null_assertion:
///         ignored_types:
///           - IMap
///           - BuiltMap
/// ```
///
/// ### Example
/// #### BAD:
///
/// ```dart
/// Object? object;
/// int? number;
///
/// final int computed = 1 + number!; // LINT
/// object!.method(); // LINT
/// ```
///
/// #### GOOD:
/// ```dart
/// Object? object;
/// int? number;
///
/// if (number != null) {
///   final int computed = 1 + number;
/// }
/// object?.method();
///
/// // No lint on maps
/// final map = {'key': 'value'};
/// map['key']!;
/// ```
class AvoidNonNullAssertionRule
    extends SolidLintRule<AvoidNonNullAssertionParameters> {
  /// Name of the lint
  static const String lintName = 'avoid_non_null_assertion';

  /// Lint code used for suppression and reporting
  static const LintCode _code = LintCode(
    lintName,
    'Avoid using the bang operator. It may result in runtime exceptions.',
  );

  /// creates an instance of [AvoidNonNullAssertionRule]
  AvoidNonNullAssertionRule({required super.analysisOptionsLoader})
    : super.withParameters(
        name: lintName,
        description:
            'Warns about usages of bang operator (!) except valid Map access.',
        parametersParser: AvoidNonNullAssertionParameters.fromJson,
      );

  @override
  LintCode get diagnosticCode => _code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final parameters =
        getParametersForContext(context) ??
        AvoidNonNullAssertionParameters.empty();

    registry.addPostfixExpression(
      this,
      AvoidNonNullAssertionVisitor(this, parameters),
    );
  }
}
