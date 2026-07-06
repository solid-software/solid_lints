import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/error/error.dart';
import 'package:solid_lints/src/lints/avoid_late_keyword/models/avoid_late_keyword_parameters.dart';
import 'package:solid_lints/src/lints/avoid_late_keyword/visitors/avoid_late_keyword_visitor.dart';
import 'package:solid_lints/src/models/solid_lint_rule.dart';

/// Avoid `late` keyword
///
/// Using `late` disables compile time safety for what would else be a nullable
/// variable. Instead, a runtime check is made, which may throw an unexpected
/// exception for an uninitialized variable.
///
/// ### Example config:
///
/// ```yaml
/// custom_lint:
///    rules:
///      - avoid_late_keyword:
///        allow_initialized: false
///        ignored_types:
///         - AnimationController
///         - ColorTween
/// ```
///
/// ### Example
///
/// #### BAD:
/// ```dart
/// class AvoidLateKeyword {
///   late final int field; // LINT
///
///   void test() {
///     late final local = ''; // LINT
///   }
/// }
/// ```
///
/// #### GOOD:
/// ```dart
/// class AvoidLateKeyword {
///   final int? field; // LINT
///
///   void test() {
///     final local = ''; // LINT
///   }
/// }
/// ```
class AvoidLateKeywordRule extends SolidLintRule<AvoidLateKeywordParameters> {
  /// The lint rule name. Must be public to generate docs.
  static const String lintName = 'avoid_late_keyword';

  static const LintCode _code = LintCode(
    lintName,
    'Avoid using the "late" keyword. It may result in runtime exceptions.',
  );

  /// Creates an instance of [AvoidLateKeywordRule].
  AvoidLateKeywordRule({required super.analysisOptionsLoader})
      : super.withParameters(
          name: lintName,
          description: 'Warns against using the late keyword.',
          parametersParser: AvoidLateKeywordParameters.fromJson,
        );

  @override
  LintCode get diagnosticCode => _code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final parameters =
        getParametersForContext(context) ?? const AvoidLateKeywordParameters();

    final visitor = AvoidLateKeywordVisitor(this, parameters);

    registry.addVariableDeclaration(
      this,
      visitor,
    );
  }
}
