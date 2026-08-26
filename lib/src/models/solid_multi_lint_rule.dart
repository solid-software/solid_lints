import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:solid_lints/src/common/parameter_parser/analysis_options_loader.dart';
import 'package:solid_lints/src/models/rule_parameters_parser.dart';
import 'package:solid_lints/src/models/solid_lint_rule.dart';

/// A base class for lint rules that report multiple diagnostic codes
/// and require configuration parameters from analysis options.
///
/// Mirrors [SolidLintRule] but extends [MultiAnalysisRule] instead of
/// [AnalysisRule], allowing rules to define multiple diagnostic codes.
abstract class SolidMultiLintRule<T extends Object?> extends MultiAnalysisRule {
  /// The loader used to read analysis options, rule parameters, and check
  /// file exclusions.
  final AnalysisOptionsLoader analysisOptionsLoader;

  final RuleParametersParser<T> _parametersParser;

  /// Constructor for [SolidMultiLintRule] model with parameters.
  SolidMultiLintRule({
    required this.analysisOptionsLoader,
    required this._parametersParser,
    required super.name,
    required super.description,
    super.state,
  });

  /// Reads the rule parameters from analysis options and parses them to [T].
  T? getParametersForContext(RuleContext context) {
    analysisOptionsLoader.loadRulesOptionsFromContext(context);

    final unparsedParameters = analysisOptionsLoader.getRuleOptions(
      context,
      name,
    );

    if (unparsedParameters == null) return null;

    return _parametersParser(unparsedParameters);
  }
}
