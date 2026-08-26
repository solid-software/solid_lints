import 'package:analysis_server_plugin/edit/change_builder/change_builder.dart';
import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analysis_server_plugin/edit/fix/fix.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:solid_lints/src/lints/use_nearest_context/use_nearest_context_rule.dart';
import 'package:solid_lints/src/lints/use_nearest_context/utils/use_nearest_context_utils.dart';

/// A Quick fix for [UseNearestContextRule] rule
/// Suggests to rename the nearest BuildContext parameter
/// to the one that is being used.
class RenameNearestContextParameterFix extends ResolvedCorrectionProducer {
  static const _renameParameterKind = FixKind(
    'solid_lints.fix.${UseNearestContextRule.lintName}.rename_parameter',
    DartFixKindPriority.standard,
    "Rename nearest BuildContext parameter",
  );

  /// Creates a new instance of [RenameNearestContextParameterFix].
  RenameNearestContextParameterFix({required super.context});

  @override
  FixKind get fixKind => _renameParameterKind;

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.automatically;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final identifierNode = node;
    if (identifierNode is! SimpleIdentifier) return;

    // Do not offer renaming the parameter if this is an access on `this`
    // or `super`.
    final parent = identifierNode.parent;
    if (parent is PropertyAccess) {
      var target = parent.target;
      while (target is ParenthesizedExpression) {
        target = target.expression;
      }
      if (target is ThisExpression || target is SuperExpression) return;
    }

    final closestBuildContext = findClosestBuildContext(identifierNode);
    if (closestBuildContext == null) return;

    final parameterName = closestBuildContext.name;
    if (parameterName == null) return;

    await builder.addDartFileEdit(file, (builder) {
      builder.addSimpleReplacement(
        parameterName.sourceRange,
        identifierNode.name,
      );
    });
  }
}
