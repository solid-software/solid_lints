part of 'double_literal_format_rule.dart';

/// Useful extensions for double literals representation
extension _StringDoubleEx on String {
  /// Returns true if a double literal starts with 00
  bool get hasLeadingZero => startsWith('0') && this[1] != '.';

  /// Returns true if a double literal starts with .
  bool get hasLeadingDecimalPoint => startsWith('.');

  /// Returns true if a mantissa of a double literal ends with 0
  bool get hasTrailingZero {
    final mantissa = split('e').first;

    return mantissa.contains('.') &&
        mantissa.endsWith('0') &&
        mantissa.split('.').last != '0';
  }
}
