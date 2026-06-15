import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:solid_lints/src/lints/avoid_unnecessary_type_casts/avoid_unnecessary_type_casts_rule.dart';

/// A Quick fix for `avoid_unnecessary_type_casts` rule
/// Suggests to remove unnecessary assertions
class AvoidUnnecessaryTypeCastsFix extends ParsedCorrectionProducer {
  static const _avoidUnnecessaryTypeCastsKind = FixKind(
    'solid_lints.fix.${AvoidUnnecessaryTypeCastsRule.lintName}',
    DartFixKindPriority.standard,
    "Remove unnecessary type cast",
  );

  @override
  FixKind get fixKind => _avoidUnnecessaryTypeCastsKind;

  @override
  FixKind get multiFixKind => const FixKind(
    'solid_lints.fix.multi.${AvoidUnnecessaryTypeCastsRule.lintName}',
    DartFixKindPriority.standard,
    "Remove unnecessary type cast across files",
  );

  /// Creates a new instance of [AvoidUnnecessaryTypeCastsFix]
  AvoidUnnecessaryTypeCastsFix({required super.context});

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.automatically;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final asExpressionNode = node.thisOrAncestorOfType<AsExpression>();
    if (asExpressionNode == null) return;

    await builder.addDartFileEdit(file, (builder) {
      final operatorOffset = asExpressionNode.asOperator.offset;
      final targetNameLength = operatorOffset - asExpressionNode.offset;
      final removedPartLength = asExpressionNode.length - targetNameLength;

      builder.addDeletion(SourceRange(operatorOffset, removedPartLength));
    });
  }
}
