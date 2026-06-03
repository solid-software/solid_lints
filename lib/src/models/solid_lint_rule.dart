import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:solid_lints/src/common/parameter_parser/analysis_options_loader.dart';

/// A function that parses the rule parameters from analysis options json
typedef RuleParametersParser<T> = T Function(Map<String, Object?>);

/// A base class for emitting information about
/// issues with user's `.dart` files.
abstract class SolidLintRule<T extends Object?> extends AnalysisRule {
  final AnalysisOptionsLoader? _analysisOptionsLoader;

  final RuleParametersParser<T>? _parametersParser;

  /// Constructor for [SolidLintRule] model.
  SolidLintRule({
    required super.name,
    required super.description,
    super.state,
  })  : _analysisOptionsLoader = null,
        _parametersParser = null;

  /// Constructor for [SolidLintRule] model with parameters.
  SolidLintRule.withParameters({
    required AnalysisOptionsLoader analysisOptionsLoader,
    required RuleParametersParser<T> parametersParser,
    required super.name,
    required super.description,
    super.state,
  })  : _analysisOptionsLoader = analysisOptionsLoader,
        _parametersParser = parametersParser;

  /// Reads the rule parameters from analysis options and parses them to [T]
  T? getParametersForContext(RuleContext context) {
    final unparsedParameters =
        _analysisOptionsLoader?.getRuleOptions(context, name);
    if (unparsedParameters == null) return null;

    return _parametersParser?.call(unparsedParameters);
  }
}
