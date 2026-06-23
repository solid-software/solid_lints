/// Repeats [string] [times] times, joining with newlines.
///
/// Useful for generating test Dart code with a specific number of lines.
String repeatLines(String string, int times) =>
    List.generate(times, (_) => string).join('\n');
