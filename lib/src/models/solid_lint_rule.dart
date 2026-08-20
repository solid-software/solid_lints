import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:solid_lints/src/common/parameter_parser/analysis_options_loader.dart';
import 'package:solid_lints/src/models/rule_parameters_parser.dart';

/// A base class for emitting information about
/// issues with user's `.dart` files.
abstract class SolidLintRule<T extends Object?> extends AnalysisRule {
  /// The loader used to read analysis options, rule parameters, and check
  /// file exclusions.
  final AnalysisOptionsLoader? analysisOptionsLoader;

  final RuleParametersParser<T>? _parametersParser;

  /// Constructor for [SolidLintRule] model.
  SolidLintRule({
    required super.name,
    required super.description,
    super.state,
  }) : analysisOptionsLoader = null,
       _parametersParser = null;

  /// Constructor for [SolidLintRule] model with parameters.
  SolidLintRule.withParameters({
    required this.analysisOptionsLoader,
    required RuleParametersParser<T> parametersParser,
    required super.name,
    required super.description,
    super.state,
  }) : _parametersParser = parametersParser;

  /// Reads the rule parameters from analysis options and parses them to [T]
  T? getParametersForContext(RuleContext context) {
    analysisOptionsLoader?.loadRulesOptionsFromContext(context);

    final unparsedParameters = analysisOptionsLoader?.getRuleOptions(
      context,
      name,
    );
    if (unparsedParameters == null) return null;

    return _parametersParser?.call(unparsedParameters);
  }
}
