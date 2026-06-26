import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:collection/collection.dart';
import 'package:solid_lints/src/common/parameter_parser/analysis_options_loader.dart';
import 'package:solid_lints/src/lints/named_parameters_ordering/models/named_parameters_ordering_parameters.dart';
import 'package:solid_lints/src/lints/named_parameters_ordering/models/parameter_type.dart';
import 'package:solid_lints/src/lints/named_parameters_ordering/named_parameters_ordering_rule.dart';
import 'package:solid_lints/src/utils/correction_utils.dart';

/// A parameter block: the text of a parameter (including leading comments and
/// indentation) and an optional trailing comment on the same line.
typedef _ParamBlock = ({String text, String? trailingComment});

/// A Quick fix for [NamedParametersOrderingRule] rule.
class NamedParametersOrderingFix extends ResolvedCorrectionProducer {
  static const _fixKind = FixKind(
    'solid_lints.fix.named_parameters_ordering',
    DartFixKindPriority.standard,
    "Sort named parameters",
  );

  /// Creates a new instance of [NamedParametersOrderingFix].
  NamedParametersOrderingFix({required super.context});

  @override
  FixKind get fixKind => _fixKind;

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.automatically;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final parameterList = node.thisOrAncestorOfType<FormalParameterList>();
    if (parameterList == null) return;

    final namedParams = parameterList.parameters
        .where((p) => p.isNamed)
        .toList();
    if (namedParams.length < 2) return;

    final parametersOrder = _getParametersOrder();

    final sortedNamedParams = namedParams.sortedBy(
      (e) => parametersOrder.indexOf(ParameterType.fromParameter(e)),
    );

    // Check if the order is already correct (if sorting changed nothing)
    final isChanged = !const ListEquality<FormalParameter>().equals(
      namedParams,
      sortedNamedParams,
    );
    if (!isChanged) return;

    final isMultiline = utils
        .getRangeText(parameterList.sourceRange)
        .contains('\n');

    final hasComments = namedParams.any(
      (p) => p.beginToken.precedingComments != null,
    );

    final sourceStart = namedParams.first.offset;
    final sourceEnd = namedParams.last.end;

    if (!isMultiline && !hasComments) {
      // Single-line: no leading comments, simple text replacement
      return builder.addDartFileEdit(file, (builder) {
        builder.addSimpleReplacement(
          utils.createRange(sourceStart, sourceEnd),
          sortedNamedParams
              .map((p) => utils.getRangeText(p.sourceRange))
              .join(', '),
        );
      });
    }

    // Multiline: extract parameter blocks including leading and trailing
    // comments
    final (:blocks, :firstBlockStart) = _extractParamBlocks(
      namedParams,
      parameterList,
    );

    // Map sorted parameters to their corresponding blocks
    final sortedBlocks = sortedNamedParams
        .map((p) => blocks[namedParams.indexOf(p)])
        .toList();

    // Determine if original had a trailing comma after the last param
    final tokenAfterEnd = namedParams.last.endToken.next;
    final hasTrailingComma = tokenAfterEnd?.lexeme == ',';

    // Build replacement text preserving trailing comments
    final replacement = sortedBlocks.expandIndexed((i, e) {
      final isLast = i == sortedBlocks.length - 1;
      final trailingComment = e.trailingComment;
      return [
        e.text,
        if (!isLast || hasTrailingComma) ',',
        if (trailingComment != null) ' $trailingComment',
        if (!isLast) '\n',
      ];
    }).join();

    // Extend range to include the original trailing comma and any trailing
    // comment on the original last parameter's line.
    var rangeEnd = hasTrailingComma ? tokenAfterEnd!.end : sourceEnd;
    final upperBound =
        parameterList.rightDelimiter?.offset ??
        parameterList.rightParenthesis.offset;
    if (rangeEnd < upperBound) {
      final afterLast = utils.getTextRange(rangeEnd, upperBound);
      final newlineIdx = afterLast.indexOf('\n');
      if (newlineIdx != -1) {
        rangeEnd += newlineIdx;
      }
    }

    final targetRange = utils.createRange(firstBlockStart, rangeEnd);

    await builder.addDartFileEdit(file, (builder) {
      builder.addSimpleReplacement(targetRange, replacement);
    });
  }

  /// Extracts text blocks for each named parameter, including any leading
  /// comments that belong to that parameter, and detects trailing comments
  /// on the same line.
  ///
  /// Trailing comments (e.g., `// comment` after a parameter on the same line)
  /// are attributed to the parameter they follow, not the next parameter.
  ({List<_ParamBlock> blocks, int firstBlockStart}) _extractParamBlocks(
    List<FormalParameter> namedParams,
    FormalParameterList parameterList,
  ) {
    final blocks = <_ParamBlock>[];
    int? firstStart;

    final lowerBound =
        parameterList.leftDelimiter?.end ?? parameterList.leftParenthesis.end;
    final upperBound =
        parameterList.rightDelimiter?.offset ??
        parameterList.rightParenthesis.offset;

    for (int i = 0; i < namedParams.length; i++) {
      final param = namedParams[i];

      final int minOffset = i == 0 ? lowerBound : namedParams[i - 1].end;

      // Find leading comment, skipping any trailing comment that belongs
      // to the previous parameter (same line as previous param).
      var blockStart = param.offset;
      Token? leadingComment = param.beginToken.precedingComments;
      if (i > 0) {
        while (leadingComment != null) {
          final betweenText = utils.getTextRange(
            namedParams[i - 1].end,
            leadingComment.offset,
          );
          if (!betweenText.contains('\n')) {
            leadingComment = leadingComment.next;
          } else {
            break;
          }
        }
      }
      if (leadingComment != null &&
          leadingComment.offset >= minOffset &&
          leadingComment.offset < param.offset) {
        blockStart = leadingComment.offset;
      }
      final lineStart = utils.getLineThis(blockStart);
      final prefixText = utils.getTextRange(lineStart, blockStart);
      if (prefixText.trim().isEmpty) {
        blockStart = lineStart;
      }

      // Find trailing comment on the same line as this parameter.
      String? trailingComment;
      final nextParamStart = i < namedParams.length - 1
          ? namedParams[i + 1].offset
          : upperBound;
      if (param.end < nextParamStart) {
        final afterParam = utils.getTextRange(param.end, nextParamStart);
        final sameLine = afterParam.split('\n').first;
        final commentIdx = sameLine.indexOf('//');
        if (commentIdx != -1) {
          trailingComment = sameLine.substring(commentIdx);
        }
      }

      firstStart ??= blockStart;
      blocks.add((
        text: utils.getTextRange(blockStart, param.end),
        trailingComment: trailingComment,
      ));
    }

    return (
      blocks: blocks,
      firstBlockStart: firstStart ?? namedParams.first.offset,
    );
  }

  List<ParameterType> _getParametersOrder() {
    final loader = AnalysisOptionsLoader(
      resourceProvider: resourceProvider,
    );
    final options = loader.getRuleOptionsForFile(
      file,
      NamedParametersOrderingRule.lintName,
    );
    return options == null
        ? ParameterType.defaultOrder
        : NamedParametersOrderingParameters.fromJson(options).order;
  }
}
