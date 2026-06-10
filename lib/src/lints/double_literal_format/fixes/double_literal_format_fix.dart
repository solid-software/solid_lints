import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:solid_lints/src/lints/double_literal_format/double_literal_format_rule.dart';
import 'package:solid_lints/src/lints/double_literal_format/double_literal_format_utils.dart';

/// A Quick fix for [DoubleLiteralFormatRule] rule
/// Suggests the correct value for an issue
class DoubleLiteralFormatFix extends ParsedCorrectionProducer {
  static const _doubleLiteralFormatKind = FixKind(
    'solid_lints.fix.${DoubleLiteralFormatRule.lintName}',
    DartFixKindPriority.standard,
    "Fix double literal format",
  );

  /// Creates a new instance of [DoubleLiteralFormatFix].
  DoubleLiteralFormatFix({required super.context});

  @override
  FixKind get fixKind => _doubleLiteralFormatKind;

  @override
  FixKind get multiFixKind => const FixKind(
    'solid_lints.fix.multi.${DoubleLiteralFormatRule.lintName}',
    DartFixKindPriority.standard,
    "Fix double literal format across files",
  );

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.automatically;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final doubleLiteralNode = node;
    if (doubleLiteralNode is! DoubleLiteral) return;

    final lexeme = doubleLiteralNode.literal.lexeme;
    if (!lexeme.hasLeadingZero &&
        !lexeme.hasLeadingDecimalPoint &&
        !lexeme.hasTrailingZero) {
      return;
    }

    final correctLexeme = _correctTrailingZeroLexeme(
      _correctLeadingZeroLexeme(
        _correctLeadingDecimalPointLexeme(
          lexeme,
        ),
      ),
    );

    await builder.addDartFileEdit(file, (builder) {
      builder.addSimpleReplacement(
        doubleLiteralNode.sourceRange,
        correctLexeme,
      );
    });
  }

  String _correctLeadingZeroLexeme(String lexeme) => !lexeme.hasLeadingZero
      ? lexeme
      : _correctLeadingZeroLexeme(lexeme.substring(1));

  String _correctLeadingDecimalPointLexeme(String lexeme) =>
      lexeme.hasLeadingDecimalPoint ? '0$lexeme' : lexeme;

  String _correctTrailingZeroLexeme(String lexeme) {
    if (!lexeme.hasTrailingZero) {
      return lexeme;
    }

    final mantissa = lexeme.toLowerCase().split('e').first;

    return _correctTrailingZeroLexeme(
      lexeme.replaceFirst(
        mantissa,
        mantissa.substring(0, mantissa.length - 1),
      ),
    );
  }
}
