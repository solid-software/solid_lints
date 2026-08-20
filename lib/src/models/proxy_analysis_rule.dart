import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/pubspec.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:solid_lints/src/common/parameter_parser/analysis_options_loader.dart';
import 'package:solid_lints/src/models/filtering_diagnostic_reporter.dart';

/// A proxy wrapper for [AnalysisRule] that checks if the rule is disabled
/// before registering its node processors.
class ProxyAnalysisRule extends AnalysisRule {
  /// The delegated rule.
  final AnalysisRule delegate;

  /// The loader used to check if the rule is disabled.
  final AnalysisOptionsLoader loader;

  /// Creates a new instance of [ProxyAnalysisRule].
  ProxyAnalysisRule(this.delegate, this.loader)
    : super(
        name: delegate.name,
        description: delegate.description,
        state: delegate.state,
      );

  @override
  DiagnosticCode get diagnosticCode => delegate.diagnosticCode;

  @override
  bool get canUseParsedResult => delegate.canUseParsedResult;

  @override
  List<String> get incompatibleRules => delegate.incompatibleRules;

  @override
  PubspecVisitor<Object?>? get pubspecVisitor => delegate.pubspecVisitor;

  @override
  set reporter(DiagnosticReporter value) {
    super.reporter = value;
    delegate.reporter = FilteringDiagnosticReporter(value, loader);
  }

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    if (loader.isRuleDisabled(context, name)) {
      return;
    }
    if (loader.isFileExcluded(context)) {
      return;
    }
    delegate.registerNodeProcessors(registry, context);
  }
}
