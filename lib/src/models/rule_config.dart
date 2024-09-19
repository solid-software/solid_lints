import 'package:analyzer/error/error.dart' as error;
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Type definition of a value factory which allows us to map data from
/// YAML configuration to an object of type [T].
typedef RuleParameterParser<T> = T Function(Map<String, Object?> json);

/// Type definition for a problem message factory after finding a problem
/// by a given lint.
typedef RuleProblemFactory<T> = String Function(T value);

/// [RuleConfig] allows us to quickly parse a lint rule and
/// declare basic configuration for it.
class RuleConfig<T extends Object?> {
  /// Constructor for [RuleConfig] model.
  RuleConfig({
    required this.name,
    required CustomLintConfigs configs,
    required RuleProblemFactory<T> problemMessage,
    RuleParameterParser<T>? paramsParser,
  })  : enabled = configs.rules[name]?.enabled ?? false,
        parameters = paramsParser?.call(configs.rules[name]?.json ?? {}) as T,
        _problemMessageFactory = problemMessage;

  /// The [LintCode] of this lint rule that represents the error.
  final String name;

  /// A flag which indicates whether this rule was enabled by the user.
  final bool enabled;

  /// Value with a configuration for a particular rule.
  final T parameters;

  /// Factory for generating error messages.
  final RuleProblemFactory<T> _problemMessageFactory;

  /// [LintCode] which is generated based on the provided data.
  LintCode get lintCode => LintCode(
        name: name,
        problemMessage: _problemMessageFactory(parameters),
        errorSeverity: error.ErrorSeverity.WARNING,
      );
}
