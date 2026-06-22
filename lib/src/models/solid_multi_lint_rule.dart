import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:solid_lints/src/common/parameter_parser/analysis_options_loader.dart';
import 'package:solid_lints/src/models/rule_parameters_parser.dart';

/// A base class for lint rules that report multiple diagnostic codes
/// and require configuration parameters from analysis options.
///
/// Mirrors SolidLintRule but extends MultiAnalysisRule instead of
/// AnalysisRule, allowing rules to define multiple diagnostic codes.
abstract class SolidMultiLintRule<T extends Object?>
    extends MultiAnalysisRule {
  final AnalysisOptionsLoader _analysisOptionsLoader;

  final RuleParametersParser<T> _parametersParser;

  /// Constructor for [SolidMultiLintRule] model with parameters.
  SolidMultiLintRule({
    required AnalysisOptionsLoader analysisOptionsLoader,
    required RuleParametersParser<T> parametersParser,
    required super.name,
    required super.description,
    super.state,
  })  : _analysisOptionsLoader = analysisOptionsLoader,
        _parametersParser = parametersParser;

  /// Reads the rule parameters from analysis options and parses them to [T].
  T? getParametersForContext(RuleContext context) {
    _analysisOptionsLoader.loadRulesOptionsFromContext(context);

    final unparsedParameters =
        _analysisOptionsLoader.getRuleOptions(context, name);
    if (unparsedParameters == null) return null;

    return _parametersParser(unparsedParameters);
  }
}
