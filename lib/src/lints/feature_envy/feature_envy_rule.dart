import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/error/error.dart';
import 'package:solid_lints/src/lints/feature_envy/models/feature_envy_parameters.dart';
import 'package:solid_lints/src/lints/feature_envy/visitors/feature_envy_visitor.dart';
import 'package:solid_lints/src/models/solid_lint_rule.dart';

/// Warns if a method accesses fields or methods from a different class
/// more often than from its own class (feature envy).
///
/// ### Example
/// BAD:
/// ```dart
/// class A {
///   int field;
///   A(this.field);
/// }
///
/// class B {
///   int method(A a) => a.field * a.field; // LINT
/// }
/// ```
///
/// GOOD:
/// ```dart
/// class A {
///   int field;
///   A(this.field);
///
///   int method() => field * field;
/// }
///
/// class B {
///   int method(A a) => a.method();
/// }
/// ```
///
/// ### Detection Algorithm
/// The rule detects feature envy using three metrics:
/// - **ATFD** (Access to Foreign Data): Accesses to members of a single
///   external class. Triggers if ATFD >= threshold (default 4).
/// - **LAA** (Locality of Attribute Access): The ratio of internal accesses
///   to total accesses. Triggers if LAA < threshold (default 0.33).
/// - **FDP** (Foreign Data Providers): The number of unique external classes
///   accessed. Triggers if FDP <= threshold (default 2).
///
/// Accesses to other instances of the same class, non-project classes,
/// closures, nested functions, and data classes are ignored.
class FeatureEnvyRule extends SolidLintRule<FeatureEnvyParameters> {
  /// Name of the lint.
  static const lintName = 'feature_envy';

  static const _code = LintCode(
    lintName,
    "Avoid accessing members of `{0}` in `{1}` more often than own members.",
    correctionMessage:
        "Consider moving the related logic into the `{0}` class.",
  );

  @override
  DiagnosticCode get diagnosticCode => _code;

  /// Creates a new instance of [FeatureEnvyRule].
  FeatureEnvyRule({
    required super.analysisOptionsLoader,
  }) : super.withParameters(
         name: lintName,
         description:
             'Warns if a method accesses members of another class more '
             'often than its own (feature envy).',
         parametersParser: FeatureEnvyParameters.fromJson,
       );

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    super.registerNodeProcessors(registry, context);

    final parameters =
        getParametersForContext(context) ?? FeatureEnvyParameters.empty();

    registry.addMethodDeclaration(
      this,
      FeatureEnvyVisitor(this, parameters),
    );
  }
}
