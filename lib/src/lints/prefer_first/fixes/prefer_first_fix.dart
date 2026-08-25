import 'package:analysis_server_plugin/edit/change_builder/change_builder.dart';
import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analysis_server_plugin/edit/fix/fix.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:solid_lints/src/lints/prefer_first/prefer_first_rule.dart';

/// A Quick fix for `prefer_first` rule
/// Suggests to replace iterable access expressions
class PreferFirstFix extends ParsedCorrectionProducer {
  static const _replaceComment = "Replace with 'first'.";

  /// Creates a new instance of [PreferFirstFix]
  PreferFirstFix({required super.context});

  @override
  FixKind get fixKind => const FixKind(
    'solid_lints.fix.${PreferFirstRule.lintName}',
    DartFixKindPriority.standard,
    _replaceComment,
  );

  @override
  FixKind get multiFixKind => const FixKind(
    'solid_lints.fix.multi.${PreferFirstRule.lintName}',
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
        return isNullAware ? '?.first' : '..first';

      case MethodInvocation(:final target?, :final isNullAware):
      case IndexExpression(:final target?, :final isNullAware):
        return isNullAware ? '$target?.first' : '$target.first';

      default:
        return '.first';
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
