import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:solid_lints/src/lints/avoid_late_keyword/models/avoid_late_keyword_parameters.dart';
import 'package:solid_lints/src/models/rule_config.dart';
import 'package:solid_lints/src/models/solid_lint_rule.dart';
import 'package:solid_lints/src/utils/types_utils.dart';

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
  /// The [LintCode] of this lint rule that represents
  /// the error whether we use `late` keyword.
  static const lintName = 'avoid_late_keyword';

  AvoidLateKeywordRule._(super.config);

  /// Creates a new instance of [AvoidLateKeywordRule]
  /// based on the lint configuration.
  factory AvoidLateKeywordRule.createRule(CustomLintConfigs configs) {
    final rule = RuleConfig(
      configs: configs,
      name: lintName,
      paramsParser: AvoidLateKeywordParameters.fromJson,
      problemMessage: (_) => 'Avoid using the "late" keyword. '
          'It may result in runtime exceptions.',
    );

    return AvoidLateKeywordRule._(rule);
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addVariableDeclaration((node) {
      if (_shouldLint(node)) {
        reporter.reportErrorForNode(code, node);
      }
    });
  }

  bool _shouldLint(VariableDeclaration node) {
    final isLateDeclaration = node.declaredElement?.isLate ?? false;
    if (!isLateDeclaration) return false;

    final hasIgnoredType = _hasIgnoredType(node);
    if (hasIgnoredType) return false;

    final allowInitialized = config.parameters.allowInitialized;
    if (!allowInitialized) return true;

    final hasInitializer = node.initializer != null;
    return !hasInitializer;
  }

  bool _hasIgnoredType(VariableDeclaration node) {
    final variableType = node.declaredElement?.type;
    if (variableType == null) return false;

    return variableType.hasIgnoredType(
      ignoredTypes: config.parameters.ignoredTypes.toSet(),
    );
  }
}
