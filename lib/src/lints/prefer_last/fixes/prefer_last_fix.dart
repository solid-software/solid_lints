import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:solid_lints/src/lints/prefer_last/prefer_last_rule.dart';

/// A Quick fix for `prefer_last` rule
/// Suggests to replace iterable access expressions
class PreferLastFix extends ParsedCorrectionProducer {
  static const _replaceComment = "Replace with 'last'.";

  /// Creates a new instance of [PreferLastFix]
  PreferLastFix({required super.context});

  @override
  FixKind get fixKind => const FixKind(
    'solid_lints.fix.${PreferLastRule.lintName}',
    DartFixKindPriority.standard,
    _replaceComment,
  );

  @override
  FixKind get multiFixKind => const FixKind(
    'solid_lints.fix.multi.${PreferLastRule.lintName}',
    DartFixKindPriority.standard,
    '$_replaceComment across files',
  );

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.automatically;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final targetNode = node.thisOrAncestorMatching(
      (n) => n is MethodInvocation || n is IndexExpression,
    );
    if (targetNode is! Expression) return;

    final correction = _createCorrection(targetNode);
    await _addReplacement(builder, targetNode, correction);
  }

  String _createCorrection(Expression expression) {
    switch (expression) {
      case MethodInvocation(isCascaded: true, :final isNullAware):
      case IndexExpression(isCascaded: true, :final isNullAware):
        return isNullAware ? '?.last' : '..last';

      case MethodInvocation(:final target?, :final isNullAware):
      case IndexExpression(:final target?, :final isNullAware):
        return isNullAware ? '$target?.last' : '$target.last';

      default:
        return '.last';
    }
  }

  Future<void> _addReplacement(
    ChangeBuilder builder,
    AstNode node,
    String correction,
  ) async {
    await builder.addDartFileEdit(
      file,
      (builder) => builder.addSimpleReplacement(node.sourceRange, correction),
    );
  }
}
