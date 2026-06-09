import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/assist/assist.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:solid_lints/src/lints/avoid_unnecessary_type_assertions/avoid_unnecessary_type_assertions_rule.dart';

/// A Quick fix for `avoid_unnecessary_type_assertions` rule
/// Suggests to remove unnecessary assertions
class AvoidUnnecessaryTypeAssertionsFix extends ResolvedCorrectionProducer {
  static const _avoidUnnecessaryTypeAssertionsAssistKind = AssistKind(
    'solid_lints.fix.${AvoidUnnecessaryTypeAssertionsRule.lintName}',
    DartFixKindPriority.standard,
    'Remove the unnecessary "{0}"',
  );

  String _itemToDelete = 'type assertion';

  @override
  List<String>? get fixArguments => [_itemToDelete];

  @override
  AssistKind get assistKind => _avoidUnnecessaryTypeAssertionsAssistKind;

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.automatically;

  /// Creates a new instance of [AvoidUnnecessaryTypeAssertionsFix]
  AvoidUnnecessaryTypeAssertionsFix({required super.context});

  @override
  Future<void> compute(ChangeBuilder builder) async {
    if (node case final IsExpression node) {
      _itemToDelete = AvoidUnnecessaryTypeAssertionsRule.operatorIsName;
      await _addDeletion(builder, node, node.isOperator.offset);
    } else if (node case final MethodInvocation node) {
      _itemToDelete = AvoidUnnecessaryTypeAssertionsRule.whereTypeMethodName;
      await _addDeletion(
        builder,
        node,
        node.operator?.offset ?? node.offset,
      );
    }
  }

  Future<void> _addDeletion(
    ChangeBuilder builder,
    Expression node,
    int operatorOffset,
  ) async {
    final targetNameLength = operatorOffset - node.offset;
    final removedPartLength = node.length - targetNameLength;

    await builder.addDartFileEdit(file, (builder) {
      builder.addDeletion(SourceRange(operatorOffset, removedPartLength));
    });
  }
}
