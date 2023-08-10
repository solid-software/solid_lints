import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Type definition of a value factory which allows us to map data from
/// YAML configuration to an object of type [T].
typedef MetricRuleValueFactory<T> = T Function(Map<String, Object?> json);

/// Type definition for a problem message factory after finding a problem
/// by a given lint.
typedef MetricRuleProblemFactory<T> = String Function(T value);

/// [MetricRule] allows us to quickly parse a lint rule and
/// declare basic configuration for it.
class MetricRule<T> {
  /// Constructor for [MetricRule] model.
  MetricRule({
    required this.name,
    required CustomLintConfigs configs,
    required MetricRuleProblemFactory<T> problemMessage,
    MetricRuleValueFactory<T>? factory,
  })  : enabled = configs.rules[name]?.enabled ?? false,
        parameters = factory?.call(configs.rules[name]?.json ?? {}) as T,
        _problemMessageFactory = problemMessage;

  /// The [LintCode] of this lint rule that represents the error.
  final String name;

  /// A flag which indicates whether this rule was enabled by the user.
  final bool enabled;

  /// Value with a configuration for a particular rule.
  final T parameters;

  /// Factory for generating error messages.
  final MetricRuleProblemFactory<T> _problemMessageFactory;

  /// [LintCode] which is generated based on the provided data.
  LintCode get lintCode => LintCode(
        name: name,
        problemMessage: _problemMessageFactory(parameters),
      );
}
