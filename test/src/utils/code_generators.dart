/// Extension utilities for generating test code.
extension RepeatLinesExtension on String {
  /// Repeats this string [times] times, joining with newlines.
  ///
  /// Useful for generating test Dart code with a specific number of lines.
  String repeatLines(int times) =>
      List.generate(times, (_) => this).join('\n');
}
