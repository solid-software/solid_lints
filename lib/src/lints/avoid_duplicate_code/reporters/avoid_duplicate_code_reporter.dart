import 'package:analyzer/diagnostic/diagnostic.dart';
import 'package:collection/collection.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/avoid_duplicate_code_rule.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/models/duplicate_location.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/models/hash_entry.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/models/literal_info.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/reporters/duplicate_report_context.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/services/differing_literals_analyzer.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/utils/range_extension.dart';
import 'package:solid_lints/src/models/solid_diagnostic_message.dart';

/// Handles diagnostic reporting and context message formatting for duplicate
/// code candidates.
class AvoidDuplicateCodeReporter {
  static const _exactDuplicateContextMessage = 'Exact duplicate';
  static const _differentLiteralsDuplicateContextMessage =
      'Duplicate with different literals';

  final AvoidDuplicateCodeRule _rule;
  final DifferingLiteralsAnalyzer _literalsAnalyzer;

  /// Creates a new [AvoidDuplicateCodeReporter].
  const AvoidDuplicateCodeReporter({
    required AvoidDuplicateCodeRule rule,
    required DifferingLiteralsAnalyzer literalsAnalyzer,
  }) : _rule = rule,
       _literalsAnalyzer = literalsAnalyzer;

  /// Reports duplicate lint diagnostics for duplicate contexts of a file.
  void report({
    required String filePath,
    required List<DuplicateReportContext> contexts,
    required Map<int, List<DuplicateLocation>> crossFileDuplicatesByHash,
  }) {
    final hashGroups = groupBy(contexts, (c) => c.entry.hash);
    final suppressedRanges = <(int, int)>[];
    final reportedOffsets = <int>{};

    for (final context in contexts) {
      final HashEntry(:hash, :offset, :range) = context.entry;
      final group = hashGroups[hash];
      if (group == null ||
          reportedOffsets.contains(offset) ||
          suppressedRanges.anyContainsStrictly(range)) {
        continue;
      }

      final internalPartners = group
          .where(
            (c) =>
                c.entry.offset != offset &&
                !suppressedRanges.anyContainsStrictly(c.entry.range),
          )
          .toList();
      final externalPartners = crossFileDuplicatesByHash[hash] ?? const [];

      if (internalPartners.isEmpty && externalPartners.isEmpty) continue;

      _report(
        filePath: filePath,
        target: context,
        internalPartners: internalPartners,
        externalPartners: externalPartners,
      );

      reportedOffsets.add(offset);
      suppressedRanges.add(range);
    }
  }

  void _report({
    required String filePath,
    required DuplicateReportContext target,
    required List<DuplicateReportContext> internalPartners,
    required List<DuplicateLocation> externalPartners,
  }) {
    final currentExactHash = target.entry.exactHash;
    final internalEntries = internalPartners.map((p) => p.entry).toList();

    final hasExactPartner = internalEntries
        .followedBy(externalPartners.map((p) => p.entry))
        .map((p) => p.exactHash)
        .contains(currentExactHash);

    final (diagnosticCode, arguments) = switch (hasExactPartner) {
      true => (_rule.exactCode, const <String>[]),
      false => (
        _rule.differentLiteralsCode,
        [
          _computeLiteralsSummary(
            currentLiterals: target.collectLiterals(_literalsAnalyzer),
            partnerLiterals: [
              for (final p in internalPartners)
                p.collectLiterals(_literalsAnalyzer),
              ..._loadExternalLiterals(externalPartners),
            ],
          ),
        ],
      ),
    };

    final contextMessages = _buildContextMessages(
      currentFilePath: filePath,
      currentExactHash: currentExactHash,
      externalPartners: externalPartners,
      internalPartners: internalEntries,
    );

    target.report(
      _rule,
      diagnosticCode: diagnosticCode,
      arguments: arguments,
      contextMessages: contextMessages,
    );
  }

  Iterable<List<LiteralInfo>> _loadExternalLiterals(
    List<DuplicateLocation> locations,
  ) => locations
      .map(_literalsAnalyzer.loadExternalLiterals)
      .nonNulls
      .where((list) => list.isNotEmpty);

  String _computeLiteralsSummary({
    required List<LiteralInfo> currentLiterals,
    required List<List<LiteralInfo>> partnerLiterals,
  }) {
    if (currentLiterals.isEmpty) return '';

    return _literalsAnalyzer.computeLiteralsSummary(
      currentLiterals: currentLiterals,
      partnerLiteralsList: partnerLiterals,
    );
  }

  List<DiagnosticMessage> _buildContextMessages({
    required String currentFilePath,
    required int currentExactHash,
    required List<DuplicateLocation> externalPartners,
    required Iterable<HashEntry> internalPartners,
  }) {
    String messageFor(int exactHash) => exactHash == currentExactHash
        ? _exactDuplicateContextMessage
        : _differentLiteralsDuplicateContextMessage;

    return [
      ...externalPartners.map(
        (location) => SolidDiagnosticMessage(
          filePath: location.filePath,
          offset: location.entry.offset,
          length: location.entry.length,
          message: messageFor(location.entry.exactHash),
        ),
      ),
      ...internalPartners.map(
        (entry) => SolidDiagnosticMessage(
          filePath: currentFilePath,
          offset: entry.offset,
          length: entry.length,
          message: messageFor(entry.exactHash),
        ),
      ),
    ];
  }
}
