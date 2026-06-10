import 'package:solid_lints/src/lints/double_literal_format/double_literal_format_rule.dart';

/// Extension to quickly check double literal formatting according to
/// [DoubleLiteralFormatRule].
extension DoubleLiteralFormatUtils on String {
  /// Returns true if a double literal starts with 00
  bool get hasLeadingZero => startsWith('0') && this[1] != '.';

  /// Returns true if a double literal starts with .
  bool get hasLeadingDecimalPoint => startsWith('.');

  /// Returns true if a mantissa of a double literal ends with 0
  bool get hasTrailingZero {
    final mantissa = toLowerCase().split('e').first;

    return mantissa.contains('.') &&
        mantissa.endsWith('0') &&
        mantissa.split('.').last != '0';
  }
}
