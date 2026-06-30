import 'package:analyzer_testing/src/analysis_rule/pub_package_resolution.dart';

/// Holds data about a lint placeholder, including the original code
/// and optional diagnostic assertions.
class AutoLintData {
  final String code;
  final Pattern? correctionContains;
  final List<Pattern> messageContainsAll;
  final String? name;
  final List<ExpectedContextMessage>? contextMessages;

  const AutoLintData({
    required this.code,
    this.correctionContains,
    this.messageContainsAll = const [],
    this.name,
    this.contextMessages,
  });
}
