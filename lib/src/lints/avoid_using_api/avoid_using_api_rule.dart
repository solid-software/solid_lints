import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/error/error.dart';
import 'package:solid_lints/src/lints/avoid_using_api/models/avoid_using_api_parameters.dart';
import 'package:solid_lints/src/lints/avoid_using_api/visitors/avoid_using_api_visitor.dart';
import 'package:solid_lints/src/models/solid_lint_rule.dart';

/// A `avoid_using_api` rule which warns about usage of avoided APIs.
///
/// You can configure specific classes, methods, or packages that should be
/// avoided in your codebase, along with custom warning messages.
///
/// ### Example config:
///
/// ```yaml
/// plugins:
///   solid_lints:
///     diagnostics:
///       avoid_using_api:
///         entries:
///           - class_name: LegacyClient
///             source: package:legacy_api/legacy_api.dart
///             reason: 'Use ModernClient instead.'
///           - identifier: print
///             source: dart:core
///             reason: 'Use logging framework instead.'
/// ```
class AvoidUsingApiRule extends SolidLintRule<AvoidUsingApiParameters> {
  /// This lint name.
  static const String lintName = 'avoid_using_api';

  /// The default lint message when no reason is provided.
  static const String defaultMessage =
      'Usage of this code has been discouraged by your project.';

  static const _code = LintCode(
    lintName,
    defaultMessage,
  );

  @override
  DiagnosticCode get diagnosticCode => _code;

  /// Creates a new instance of [AvoidUsingApiRule].
  AvoidUsingApiRule({
    required super.analysisOptionsLoader,
  }) : super.withParameters(
          name: lintName,
          description: 'Avoid using specific APIs.',
          parametersParser: AvoidUsingApiParameters.fromJson,
        );

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    super.registerNodeProcessors(registry, context);

    final parameters =
        getParametersForContext(context) ?? AvoidUsingApiParameters.empty();
    if (parameters.entries.isEmpty) {
      return;
    }

    final visitor = AvoidUsingApiVisitor(
      parameters: parameters,
      context: context,
    );

    registry.addSimpleIdentifier(this, visitor);
    registry.addNamedType(this, visitor);
    registry.addVariableDeclaration(this, visitor);
    registry.addInstanceCreationExpression(this, visitor);
    registry.addMethodInvocation(this, visitor);
  }
}
