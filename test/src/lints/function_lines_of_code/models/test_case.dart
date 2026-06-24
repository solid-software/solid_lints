/// Parameters for a single function_lines_of_code test case.
class TestCase {
  /// Number of code lines inside the function body.
  ///
  /// `var i = 0;` and `return i;` are always present, so [codeLines] of 4
  /// means two extra `i++;` statements.
  final int codeLines;

  /// Whether to include single-line and multi-line comments (not counted).
  final bool comments;

  /// If set, wraps the function inside `class [className] { ... }`.
  final String? className;

  /// Overrides the default function name (`function`).
  final String? methodName;

  /// If true, generates an anonymous function literal instead.
  final bool anonymous;

  const TestCase({
    required this.codeLines,
    this.comments = false,
    this.className,
    this.methodName,
    this.anonymous = false,
  });

  @override
  String toString() {
    final parts = <String>['codeLines: $codeLines'];
    if (comments) parts.add('comments: true');
    if (className != null) parts.add('className: $className');
    if (methodName != null) parts.add('methodName: $methodName');
    if (anonymous) parts.add('anonymous: true');
    return '(${parts.join(', ')})';
  }
}
