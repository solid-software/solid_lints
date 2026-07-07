import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/error/error.dart';
import 'package:solid_lints/src/lints/named_parameters_ordering/fixes/named_parameters_ordering_fix.dart';
import 'package:solid_lints/src/lints/named_parameters_ordering/models/named_parameters_ordering_parameters.dart';
import 'package:solid_lints/src/lints/named_parameters_ordering/models/parameter_type.dart';
import 'package:solid_lints/src/lints/named_parameters_ordering/visitors/named_parameters_ordering_visitor.dart';
import 'package:solid_lints/src/models/rule_with_fixes.dart';
import 'package:solid_lints/src/models/solid_lint_rule.dart';

/// A lint which allows to enforce a particular named parameter ordering
/// conventions.
///
/// ### Configuration format
/// ```yaml
///  - named_parameters_ordering:
///    order:
///      - (parameterType)
/// ```
/// Where parameterType can be one of:
///
/// - `super`
/// - `required_super`
/// - `required`
/// - `nullable`
/// - `default`
///
/// ### Example:
///
/// Assuming config:
///
/// ```yaml
/// plugins:
///   solid_lints:
///     diagnostics:
///       named_parameters_ordering:
///         order:
///           - required
///           - required_super
///           - default
///           - nullable
///           - super
/// ```
///
/// #### BAD:
///
/// ```dart
/// class UserProfile extends User {
///   final String? age;
///   final String? country;
///   final String email;
///   final bool isActive;
///   final String name;
///
///   UserProfile({
///     this.age,
///     required super.accountType, // LINT, required super named parameters should be before nullable named parameters
///     required this.name, // LINT, required named parameters should be before super named parameters
///     super.userId,
///     this.country, // LINT, nullable named parameters should be before super named parameters
///     this.isActive = true, // LINT, default named parameters should be before nullable named parameters
///     required this.email, // LINT, required named parameters should be before default named parameters
///   });
///
///   void doSomething({
///     required String name,
///     int? age,
///     bool isActive = true, // LINT, default named parameters should be before nullable named parameters
///     required String email, // LINT, required named parameters should be before default named parameters
///   }) {
///     return;
///   }
/// }
/// ```
///
/// #### GOOD:
///
/// ```dart
/// class UserProfile extends User {
///   final String? age;
///   final String? country;
///   final String email;
///   final bool isActive;
///   final String name;
///
///   UserProfile({
///     required this.name,
///     required this.email,
///     required super.accountType,
///     this.isActive = true,
///     this.age,
///     this.country,
///     super.userId,
///   });
///
///   void doSomething({
///     required String name,
///     required String email,
///     bool isActive = true,
///     int? age,
///   }) {
///     return;
///   }
/// }
/// ```
class NamedParametersOrderingRule
    extends SolidLintRule<NamedParametersOrderingParameters>
    implements RuleWithFixes {
  /// The name of this lint rule.
  static const lintName = 'named_parameters_ordering';

  /// The [LintCode] for this rule.
  static const code = LintCode(
    lintName,
    '{0} named parameters should be before {1} named parameters.',
  );

  /// Creates a new instance of [NamedParametersOrderingRule].
  NamedParametersOrderingRule({
    required super.analysisOptionsLoader,
  }) : super.withParameters(
         name: lintName,
         description:
             'A lint which allows to enforce a particular named parameter '
             'ordering conventions.',
         parametersParser: NamedParametersOrderingParameters.fromJson,
       );

  @override
  LintCode get diagnosticCode => code;

  @override
  Iterable<MapEntry<DiagnosticCode, ProducerGenerator>> get fixesForCodes =>
      const [MapEntry(code, NamedParametersOrderingFix.new)];

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    super.registerNodeProcessors(registry, context);

    final parameters =
        getParametersForContext(context) ??
        const NamedParametersOrderingParameters(
          order: ParameterType.defaultOrder,
        );

    final visitor = NamedParametersOrderingVisitor(this, parameters.order);

    registry.addFormalParameterList(this, visitor);
  }
}
