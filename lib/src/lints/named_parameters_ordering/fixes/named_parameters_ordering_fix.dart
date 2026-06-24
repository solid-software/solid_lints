import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:solid_lints/src/common/parameter_parser/analysis_options_loader.dart';
import 'package:solid_lints/src/lints/named_parameters_ordering/models/named_parameters_ordering_parameters.dart';
import 'package:solid_lints/src/lints/named_parameters_ordering/models/parameter_type.dart';
import 'package:solid_lints/src/lints/named_parameters_ordering/named_parameters_ordering_rule.dart';

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

    final sortedNamedParams = [...namedParams];
    sortedNamedParams.sort((a, b) {
      final typeA = ParameterType.fromParameter(a);
      final typeB = ParameterType.fromParameter(b);
      final indexA = parametersOrder.indexOf(typeA);
      final indexB = parametersOrder.indexOf(typeB);
      return indexA.compareTo(indexB);
    });

    // Check if the order is already correct (if sorting changed nothing)
    bool isChanged = false;
    for (int i = 0; i < namedParams.length; i++) {
      if (namedParams[i] != sortedNamedParams[i]) {
        isChanged = true;
        break;
      }
    }
    if (!isChanged) return;

    final isMultiline = utils
        .getRangeText(parameterList.sourceRange)
        .contains('\n');

    final hasComments = namedParams.any(
      (p) => p.beginToken.precedingComments != null,
    );

    if (!isMultiline && !hasComments) {
      // Single-line: no leading comments, simple text replacement
      final sortedTexts = sortedNamedParams
          .map((p) => utils.getRangeText(p.sourceRange))
          .toList();

      final replacementText = sortedTexts.join(', ');

      final targetRange = SourceRange(
        namedParams.first.offset,
        namedParams.last.end - namedParams.first.offset,
      );

      await builder.addDartFileEdit(file, (builder) {
        builder.addSimpleReplacement(targetRange, replacementText);
      });
      return;
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
    final hasTrailingComma = namedParams.last.endToken.next?.lexeme == ',';

    // Build replacement text preserving trailing comments
    final buffer = StringBuffer();
    for (int i = 0; i < sortedBlocks.length; i++) {
      buffer.write(sortedBlocks[i].text);

      final isLast = i == sortedBlocks.length - 1;
      if (!isLast || hasTrailingComma) {
        buffer.write(',');
      }
      final trailingComment = sortedBlocks[i].trailingComment;
      if (trailingComment != null) {
        buffer.write(' $trailingComment');
      }
      if (!isLast) {
        buffer.write('\n');
      }
    }

    // Extend range to include the original trailing comma and any trailing
    // comment on the original last parameter's line.
    var rangeEnd = namedParams.last.end;
    if (hasTrailingComma) {
      rangeEnd = namedParams.last.endToken.next!.end;
    }
    final upperBound =
        parameterList.rightDelimiter?.offset ??
        parameterList.rightParenthesis.offset;
    if (rangeEnd < upperBound) {
      final afterLast = utils.getRangeText(
        SourceRange(rangeEnd, upperBound - rangeEnd),
      );
      final newlineIdx = afterLast.indexOf('\n');
      if (newlineIdx != -1) {
        rangeEnd += newlineIdx;
      }
    }

    final targetRange = SourceRange(
      firstBlockStart,
      rangeEnd - firstBlockStart,
    );

    await builder.addDartFileEdit(file, (builder) {
      builder.addSimpleReplacement(targetRange, buffer.toString());
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

    for (int i = 0; i < namedParams.length; i++) {
      final param = namedParams[i];

      final int minOffset = i == 0
          ? (parameterList.leftDelimiter?.end ??
                parameterList.leftParenthesis.end)
          : namedParams[i - 1].end;

      // Find leading comment, skipping any trailing comment that belongs
      // to the previous parameter (same line as previous param).
      var blockStart = param.offset;
      Token? leadingComment = param.beginToken.precedingComments;
      if (i > 0 && leadingComment != null) {
        final betweenText = utils.getRangeText(
          SourceRange(
            namedParams[i - 1].end,
            leadingComment.offset - namedParams[i - 1].end,
          ),
        );
        if (!betweenText.contains('\n')) {
          // This comment is a trailing comment of the previous param.
          // Try the next comment in the chain as our leading comment.
          final nextComment = leadingComment.next;
          leadingComment =
              nextComment != null &&
                  nextComment.offset >= minOffset &&
                  nextComment.offset < param.offset
              ? nextComment
              : null;
        }
      }
      if (leadingComment != null &&
          leadingComment.offset >= minOffset &&
          leadingComment.offset < param.offset) {
        blockStart = leadingComment.offset;
      }
      final lineStart = utils.getLineThis(blockStart);
      final prefixText = utils.getRangeText(
        SourceRange(lineStart, blockStart - lineStart),
      );
      if (prefixText.trim().isEmpty) {
        blockStart = lineStart;
      }

      // Find trailing comment on the same line as this parameter.
      String? trailingComment;
      final nextParamStart = i < namedParams.length - 1
          ? namedParams[i + 1].offset
          : (parameterList.rightDelimiter?.offset ??
              parameterList.rightParenthesis.offset);
      if (param.end < nextParamStart) {
        final afterParam = utils.getRangeText(
          SourceRange(param.end, nextParamStart - param.end),
        );
        final newlineIdx = afterParam.indexOf('\n');
        final sameLine = newlineIdx == -1
            ? afterParam
            : afterParam.substring(0, newlineIdx);
        final commentIdx = sameLine.indexOf('//');
        if (commentIdx != -1) {
          trailingComment = sameLine.substring(commentIdx);
        }
      }

      firstStart ??= blockStart;
      blocks.add((
        text: utils.getRangeText(
          SourceRange(blockStart, param.end - blockStart),
        ),
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
    if (options != null) {
      return NamedParametersOrderingParameters.fromJson(options).order;
    }
    return ParameterType.defaultOrder;
  }
}
