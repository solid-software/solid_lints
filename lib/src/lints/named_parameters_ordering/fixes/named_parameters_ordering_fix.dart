import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:solid_lints/src/lints/named_parameters_ordering/models/parameter_type.dart';
import 'package:solid_lints/src/lints/named_parameters_ordering/named_parameters_ordering_rule.dart';
import 'package:yaml/yaml.dart';

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

    if (!isMultiline) {
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

    // Multiline: extract parameter blocks including leading comments
    final (:blockTexts, :firstBlockStart) = _extractParamBlocks(
      namedParams,
      parameterList,
    );

    // Map sorted parameters to their corresponding block texts
    final sortedBlockTexts = sortedNamedParams
        .map((p) => blockTexts[namedParams.indexOf(p)])
        .toList();

    final replacementText = sortedBlockTexts.join(',\n');

    final targetRange = SourceRange(
      firstBlockStart,
      namedParams.last.end - firstBlockStart,
    );

    await builder.addDartFileEdit(file, (builder) {
      builder.addSimpleReplacement(targetRange, replacementText);
    });
  }

  /// Extracts text blocks for each named parameter, including any leading
  /// comments that belong to that parameter.
  ///
  /// Returns the block texts and the start offset of the first block
  /// (used as the replacement range start).
  ({List<String> blockTexts, int firstBlockStart}) _extractParamBlocks(
    List<FormalParameter> namedParams,
    FormalParameterList parameterList,
  ) {
    final blocks = <String>[];
    int? firstStart;

    for (int i = 0; i < namedParams.length; i++) {
      final param = namedParams[i];

      final int minOffset = i == 0
          ? (parameterList.leftDelimiter?.end ??
                parameterList.leftParenthesis.end)
          : namedParams[i - 1].end;

      // Find block start: use leading comment offset if present,
      // then expand to line start for proper indentation
      var blockStart = param.offset;
      final comment = param.beginToken.precedingComments;
      if (comment != null &&
          comment.offset >= minOffset &&
          comment.offset < param.offset) {
        blockStart = comment.offset;
      }
      final linePrefix = utils.getLinePrefix(blockStart);
      blockStart -= linePrefix.length;

      firstStart ??= blockStart;
      blocks.add(
        utils.getRangeText(SourceRange(blockStart, param.end - blockStart)),
      );
    }

    return (
      blockTexts: blocks,
      firstBlockStart: firstStart ?? namedParams.first.offset,
    );
  }

  List<ParameterType> _getParametersOrder() {
    final pathContext = resourceProvider.pathContext;
    String currentDirectoryPath = pathContext.dirname(file);

    while (pathContext.dirname(currentDirectoryPath) != currentDirectoryPath) {
      final candidatePath = pathContext.join(
        currentDirectoryPath,
        'analysis_options.yaml',
      );
      final candidateFile = resourceProvider.getFile(candidatePath);

      if (candidateFile.exists) {
        try {
          final content = candidateFile.readAsStringSync();
          final yaml = loadYaml(content);
          if (yaml case {
            'plugins': {
              'solid_lints': {
                'diagnostics': {
                  NamedParametersOrderingRule.lintName: {
                    'order': final List<Object?> orderList,
                  },
                },
              },
            },
          }) {
            final order = orderList
                .map((e) => e is String ? ParameterType.fromType(e) : null)
                .whereType<ParameterType>()
                .toList();
            if (order.isNotEmpty) {
              return order;
            }
          }
        } catch (_) {
          // ignore parsing error, fallback to default order
        }
        break;
      }

      final parentDir = pathContext.dirname(currentDirectoryPath);
      currentDirectoryPath = parentDir;
    }

    return ParameterType.defaultOrder;
  }
}
