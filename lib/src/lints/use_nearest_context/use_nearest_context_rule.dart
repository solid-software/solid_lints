// ignore_for_file: avoid_print, lines_longer_than_80_chars

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:solid_lints/src/models/rule_config.dart';
import 'package:solid_lints/src/models/solid_lint_rule.dart';
import 'package:solid_lints/src/utils/types_utils.dart';

part 'fixes/use_nearest_context_fix.dart';

/// A rule which checks that we use BuildContext from the nearest available
/// scope.
///
/// ### Example:
/// #### BAD:
/// ```dart
/// class SomeWidget extends StatefulWidget {
/// ...
/// }
///
/// class _SomeWidgetState extends State<SomeWidget> {
///   ...
///   void _showDialog() {
///     showModalBottomSheet(
///       context: context,
///       builder: (BuildContext _) {
///         final someProvider = context.watch<SomeProvider>(); // LINT, BuildContext is used not from the nearest available scope
///
///         return const SizedBox.shrink();
///       },
///     );
///   }
/// }
/// ```
/// #### GOOD:
/// ```dart
/// class SomeWidget extends StatefulWidget {
/// ...
/// }
///
/// class _SomeWidgetState extends State<SomeWidget> {
///   ...
///   void _showDialog() {
///     showModalBottomSheet(
///       context: context,
///       builder: (BuildContext context)
///         final someProvider = context.watch<SomeProvider>(); // OK
///
///         return const SizedBox.shrink();
///       },
///     );
///   }
/// }
/// ```
///
class UseNearestContextRule extends SolidLintRule {
  /// This lint rule represents the error if BuildContext is used not from the
  /// nearest available scope
  static const lintName = 'use_nearest_context';

  UseNearestContextRule._(super.rule);

  /// Creates a new instance of [UseNearestContextRule]
  /// based on the lint configuration.
  factory UseNearestContextRule.createRule(CustomLintConfigs configs) {
    final rule = RuleConfig(
      configs: configs,
      name: lintName,
      problemMessage: (value) =>
          'BuildContext is used not from the nearest available scope. '
          'Consider renaming the nearest BuildContext parameter.',
    );

    return UseNearestContextRule._(rule);
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addSimpleIdentifier((node) {
      if (!isBuildContext(node.staticType)) return;

      final closestBuildContext = _findClosestBuildContext(node);
      if (closestBuildContext == null) return;
      if (closestBuildContext.name?.lexeme != node.name) {
        reporter.atNode(
          node,
          code,
          data: StatementInfo(
            name: node.name,
            parameter: closestBuildContext,
          ),
        );
      }
    });
  }

  SimpleFormalParameter? _findClosestBuildContext(SimpleIdentifier node) {
    AstNode? current = node.parent;

    while (current != null) {
      if (current is FunctionExpression) {
        final functionParams = current.parameters?.parameters ?? [];
        for (final param in functionParams) {
          if (param is SimpleFormalParameter &&
              isBuildContext(param.declaredElement?.type)) {
            return param;
          }
        }
      }
      current = current.parent;
    }
    return null;
  }

  @override
  List<Fix> getFixes() => [_UseNearestContextFix()];
}
