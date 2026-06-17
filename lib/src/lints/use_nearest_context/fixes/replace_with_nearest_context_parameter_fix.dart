import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:solid_lints/src/lints/use_nearest_context/use_nearest_context_rule.dart';
import 'package:solid_lints/src/lints/use_nearest_context/utils/use_nearest_context_utils.dart';

/// A Quick fix for [UseNearestContextRule] rule
/// Suggests to replace the outer BuildContext expression
/// with the nearest available parameter.
class ReplaceWithNearestContextParameterFix extends ResolvedCorrectionProducer {
  static const _replaceExpressionKind = FixKind(
    'solid_lints.fix.${UseNearestContextRule.lintName}.replace_expression',
    DartFixKindPriority.standard,
    "Replace with nearest BuildContext parameter",
  );

  /// Creates a new instance of [ReplaceWithNearestContextParameterFix].
  ReplaceWithNearestContextParameterFix({required super.context});

  @override
  FixKind get fixKind => _replaceExpressionKind;

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.automatically;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final errorNode = node;

    final closestBuildContext = findClosestBuildContext(errorNode);
    if (closestBuildContext == null) return;

    final parameterName = closestBuildContext.name?.lexeme;
    if (parameterName == null) return;

    if (errorNode is ThisExpression) {
      await builder.addDartFileEdit(file, (builder) {
        builder.addSimpleReplacement(
          errorNode.sourceRange,
          parameterName,
        );
      });
      return;
    }

    if (errorNode is SimpleIdentifier) {
      final parent = errorNode.parent;
      if (parent is PropertyAccess) {
        var target = parent.target;
        while (target is ParenthesizedExpression) {
          target = target.expression;
        }
        if (target is ThisExpression || target is SuperExpression) {
          await builder.addDartFileEdit(file, (builder) {
            builder.addSimpleReplacement(
              parent.sourceRange,
              parameterName,
            );
          });
          return;
        }
      }
    }
  }
}
