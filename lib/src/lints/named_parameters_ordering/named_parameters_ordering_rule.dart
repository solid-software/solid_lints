import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:solid_lints/src/lints/named_parameters_ordering/models/named_parameters_ordering_parameters.dart';
import 'package:solid_lints/src/lints/named_parameters_ordering/models/parameter_ordering_info.dart';
import 'package:solid_lints/src/lints/named_parameters_ordering/visitors/named_parameters_ordering_visitor.dart';
import 'package:solid_lints/src/models/rule_config.dart';
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
/// custom_lint:
///   rules:
///     - named_parameters_ordering:
///       order:
///         - required
///         - required_super
///         - default
///         - nullable
///         - super
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
    extends SolidLintRule<NamedParametersOrderingParameters> {
  /// The name of this lint rule.
  static const lintName = 'named_parameters_ordering';

  late final _visitor = NamedParametersOrderingVisitor(config.parameters.order);

  NamedParametersOrderingRule._(super.config);

  /// Creates a new instance of [NamedParametersOrderingRule]
  /// based on the lint configuration.
  factory NamedParametersOrderingRule.createRule(CustomLintConfigs configs) {
    final config = RuleConfig<NamedParametersOrderingParameters>(
      configs: configs,
      name: lintName,
      paramsParser: NamedParametersOrderingParameters.fromJson,
      problemMessage: (_) => "Order of named parameter is wrong",
    );

    return NamedParametersOrderingRule._(config);
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addFormalParameterList((node) {
      final parametersInfo = _visitor.visitFormalParameterList(node);

      final wrongOrderParameters = parametersInfo.where(
        (info) => info.parameterOrderingInfo.isWrong,
      );

      for (final parameterInfo in wrongOrderParameters) {
        reporter.atNode(
          parameterInfo.formalParameter,
          _createWrongOrderLintCode(parameterInfo.parameterOrderingInfo),
        );
      }
    });
  }

  LintCode _createWrongOrderLintCode(ParameterOrderingInfo info) {
    final parameterOrdering = info.parameterType;
    final previousParameterOrdering = info.previousParameterType;

    return LintCode(
      name: lintName,
      problemMessage: "${parameterOrdering.displayName} named parameters"
          " should be before "
          "${previousParameterOrdering!.displayName} named parameters.",
    );
  }
}
