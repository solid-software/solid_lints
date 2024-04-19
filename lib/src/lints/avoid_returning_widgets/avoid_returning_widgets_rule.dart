import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/listener.dart';
import 'package:collection/collection.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:solid_lints/src/lints/avoid_returning_widgets/models/avoid_returning_widgets_exclude.dart';
import 'package:solid_lints/src/lints/avoid_returning_widgets/models/avoid_returning_widgets_parameters.dart';
import 'package:solid_lints/src/models/rule_config.dart';
import 'package:solid_lints/src/models/solid_lint_rule.dart';
import 'package:solid_lints/src/utils/types_utils.dart';

/// A rule which warns about returning widgets from functions and methods.
///
/// Using functions instead of Widget subclasses for decomposing Widget trees
/// may cause unexpected behavior and performance issues.
///
/// Exceptions:
///   - overriden methods
///
/// More details: https://github.com/flutter/flutter/issues/19269
///
/// ### Example
///
/// #### BAD:
///
/// ```dart
/// Widget avoidReturningWidgets() => const SizedBox(); // LINT
///
/// class MyWidget extends StatelessWidget {
///   Widget get box => SizedBox(); // LINT
///   Widget test1() => const SizedBox(); //LINT
///   Widget get _test3 => const SizedBox(); // LINT
/// }
/// ```
///
///
/// #### GOOD:
///
/// ```dart
/// class MyWidget extends MyWidget {
///
///   @override
///   Widget test1() => const SizedBox();
///
///   @override
///   Widget get box => ColoredBox(color: Colors.pink);
///
///   @override
///   Widget build(BuildContext context) {
///     return const SizedBox();
///   }
/// }
/// ```
class AvoidReturningWidgetsRule
    extends SolidLintRule<AvoidReturningWidgetsParameters> {
  /// The [LintCode] of this lint rule that represents
  /// the error whether we return a widget.
  static const lintName = 'avoid_returning_widgets';

  AvoidReturningWidgetsRule._(super.config);

  /// Creates a new instance of [AvoidReturningWidgetsRule]
  /// based on the lint configuration.
  factory AvoidReturningWidgetsRule.createRule(CustomLintConfigs configs) {
    final rule = RuleConfig(
      configs: configs,
      name: lintName,
      paramsParser: AvoidReturningWidgetsParameters.fromJson,
      problemMessage: (_) =>
          'Returning a widget from a function is considered an anti-pattern. '
          'Unless you are overriding an existing method, '
          'consider extracting your widget to a separate class.',
    );

    return AvoidReturningWidgetsRule._(rule);
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addDeclaration((node) {
      // Check if declaration is function or method,
      // simultaneously checks if return type is [DartType]
      final DartType? returnType = switch (node) {
        FunctionDeclaration(returnType: TypeAnnotation(:final type?)) ||
        MethodDeclaration(returnType: TypeAnnotation(:final type?)) =>
          type,
        _ => null,
      };

      if (returnType == null) {
        return;
      }

      final isWidgetReturned = hasWidgetType(returnType);

      final isIgnored = _hasIgnored(node, returnType);

      final isOverriden = node.declaredElement?.hasOverride ?? false;

      if (isWidgetReturned && !isOverriden && !isIgnored) {
        reporter.reportErrorForNode(code, node);
      }
    });
  }

  bool _hasIgnored(Declaration node, DartType returnType) {
    final methodName = node.declaredElement?.name;

    final excludedItem = config.parameters.exclude
        .firstWhereOrNull((e) => e.methodName == methodName);

    if (excludedItem
        case AvoidReturningWidgetsExclude(
          :final String? className,
        )) {
      if (className == null) {
        return true;
      } else {
        return returnType.hasIgnoredType(ignoredTypes: {className});
      }
    }

    return false;
  }
}
