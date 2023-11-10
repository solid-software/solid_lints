part of 'double_literal_format_rule.dart';

/// A Quick fix for `double_literal_format` rule
/// Suggests the correct value for an issue
class _DoubleLiteralFormatFix extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    context.registry.addDoubleLiteral((node) {
      // checks that the literal declaration is where our warning is located
      if (!analysisError.sourceRange.intersects(node.sourceRange)) return;

      final lexeme = node.literal.lexeme;
      String? correctLexeme;

      if (lexeme.hasLeadingZero) {
        correctLexeme = _correctLeadingZeroLexeme(lexeme);
      } else if (lexeme.hasLeadingDecimalPoint) {
        correctLexeme = _correctLeadingDecimalPointLexeme(lexeme);
      } else if (lexeme.hasTrailingZero) {
        correctLexeme = _correctTrailingZeroLexeme(lexeme);
      }

      if (correctLexeme != null) {
        final changeBuilder = reporter.createChangeBuilder(
          message: 'Replace by $correctLexeme',
          priority: 1,
        );

        changeBuilder.addDartFileEdit((builder) {
          builder.addSimpleReplacement(
            SourceRange(node.offset, node.length),
            correctLexeme!,
          );
        });
      }
    });
  }

  String _correctLeadingZeroLexeme(String lexeme) => !lexeme.hasLeadingZero
      ? lexeme
      : _correctLeadingZeroLexeme(lexeme.substring(1));

  String _correctLeadingDecimalPointLexeme(String lexeme) => '0$lexeme';

  String _correctTrailingZeroLexeme(String lexeme) {
    if (!lexeme.hasTrailingZero) {
      return lexeme;
    } else {
      final mantissa = lexeme.split('e').first;
      return _correctTrailingZeroLexeme(
        lexeme.replaceFirst(
          mantissa,
          mantissa.substring(0, mantissa.length - 1),
        ),
      );
    }
  }
}
