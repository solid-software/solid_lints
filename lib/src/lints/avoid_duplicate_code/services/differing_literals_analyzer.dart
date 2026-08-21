import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/file_system/file_system.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/models/duplicate_location.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/models/hash_entry.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/models/literal_info.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/visitors/literal_collector_visitor.dart';
import 'package:solid_lints/src/utils/function_utils.dart';
import 'package:solid_lints/src/utils/resource_provider_utils.dart';

/// Analyzes differences in literal values across duplicate code candidates.
class DifferingLiteralsAnalyzer {
  static const _maxDisplayedLiterals = 3;
  static const _bodyPrefixes = [
    '{',
    'async {',
    'async* {',
    'sync* {',
    '=>',
    'async =>',
    'async* =>',
    'sync* =>',
  ];

  final ResourceProvider _resourceProvider;
  final _fileContentCache = <String, String>{};

  /// Creates a new [DifferingLiteralsAnalyzer].
  DifferingLiteralsAnalyzer({
    required ResourceProvider resourceProvider,
  }) : _resourceProvider = resourceProvider;

  /// Loads literals for an external code clone location from the file system.
  List<LiteralInfo>? loadExternalLiterals(DuplicateLocation dup) {
    final content = _fileContentCache.putIfAbsent(
      dup.filePath,
      () => _resourceProvider.readFileContent(dup.filePath),
    );
    if (content.isEmpty) return null;

    final HashEntry(:offset, :length) = dup.entry;
    final end = offset + length;
    if (offset < 0 || length <= 0 || end > content.length) return null;

    final snippet = content.substring(offset, end);
    final wrapped = _wrapSnippet(snippet);

    return FunctionUtils.tryOrNull(() {
      final parsed = parseString(content: wrapped, throwIfDiagnostics: false);

      return LiteralCollectorVisitor.collect(parsed.unit);
    });
  }

  String _wrapSnippet(String snippet) {
    final trimmed = snippet.trimLeft();
    final isBody = _bodyPrefixes.any(trimmed.startsWith);

    return isBody ? 'void _f() $snippet' : 'void _f() {\n$snippet\n}';
  }

  /// Computes a human-readable summary of differing literal values between
  /// the [currentLiterals] and all [partnerLiteralsList].
  String computeLiteralsSummary({
    required List<LiteralInfo> currentLiterals,
    required List<List<LiteralInfo>> partnerLiteralsList,
  }) {
    if (partnerLiteralsList.isEmpty || currentLiterals.isEmpty) return '';

    final slotsFormatted = currentLiterals.indexed
        .map((entry) => _extractSlotValues(entry, partnerLiteralsList))
        .where((slots) => slots.length > 1)
        .map(_formatSlot)
        .toList();

    if (slotsFormatted.isEmpty) return '';

    final displayed = slotsFormatted.take(_maxDisplayedLiterals).join(', ');
    final remaining = slotsFormatted.length - _maxDisplayedLiterals;
    final extra = remaining > 0 ? ' (+$remaining more)' : '';

    return ': $displayed$extra';
  }

  /// Extracts all unique literal text values at the given slot [entry] index
  /// across the current clone and all [partnerLiteralsList].
  ///
  /// For example, if the current literal is `'foo'` at index `0` and partner
  /// clones have `['bar']` and `['foo']` at index `0`, this returns
  /// `{'foo', 'bar'}`.
  Set<String> _extractSlotValues(
    (int, LiteralInfo) entry,
    List<List<LiteralInfo>> partnerLiteralsList,
  ) => switch (entry) {
    (final index, final literal) => {
      literal.text,
      ...partnerLiteralsList
          .map((pLits) => pLits.elementAtOrNull(index)?.text)
          .nonNulls,
    },
  };

  /// Formats literal slot [values] into a bracketed string, truncating with
  /// `+N more` when exceeding [_maxDisplayedLiterals].
  ///
  /// Examples:
  /// - `['a', 'b']` -> `[a, b]`
  /// - `['a', 'b', 'c', 'd']` with limit `3` -> `[a, b, c, +1 more]`
  String _formatSlot(Set<String> values) {
    final remaining = values.length - _maxDisplayedLiterals;
    final items = [
      ...values.take(_maxDisplayedLiterals),
      if (remaining > 0) '+$remaining more',
    ].join(', ');

    return '[$items]';
  }
}
