import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:solid_lints/src/lints/avoid_unnecessary_type_assertions/avoid_unnecessary_type_assertions_rule.dart';

/// A Quick fix for `avoid_unnecessary_type_assertions` rule
/// Suggests to remove unnecessary assertions
class AvoidUnnecessaryTypeAssertionsFix extends ResolvedCorrectionProducer {
  static const _avoidUnnecessaryTypeAssertionsFixKind = FixKind(
    'solid_lints.fix.${AvoidUnnecessaryTypeAssertionsRule.lintName}',
    DartFixKindPriority.standard,
    'Remove the unnecessary {0}',
  );

  SourceRange? _partToRemove;

  @override
  List<String>? get fixArguments => [
    if (_partToRemove case final partToRemove?)
      '"${utils.getRangeText(partToRemove).trim()}"'
    else
      'type assertion',
  ];

  @override
  FixKind get fixKind => _avoidUnnecessaryTypeAssertionsFixKind;

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.automatically;

  /// Creates a new instance of [AvoidUnnecessaryTypeAssertionsFix]
  AvoidUnnecessaryTypeAssertionsFix({required super.context});

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final isExpressionNode = node.thisOrAncestorOfType<IsExpression>();
    if (isExpressionNode != null) {
      final operatorOffset = isExpressionNode.isOperator.offset - 1;
      _partToRemove = _removedPartRange(isExpressionNode, operatorOffset);
    }

    final whereTypeNode = node.thisOrAncestorOfType<MethodInvocation>();
    if (whereTypeNode != null && _partToRemove == null) {
      final operatorOffset =
          whereTypeNode.operator?.offset ?? whereTypeNode.offset;
      _partToRemove = _removedPartRange(whereTypeNode, operatorOffset);
    }

    final partToRemove = _partToRemove;
    if (partToRemove == null) return;

    await builder.addDartFileEdit(
      file,
      (builder) => builder.addDeletion(partToRemove),
    );
  }

  SourceRange _removedPartRange(Expression node, int operatorOffset) {
    final targetNameLength = operatorOffset - node.offset;
    final removedPartLength = node.length - targetNameLength;

    return SourceRange(operatorOffset, removedPartLength);
  }
}
