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
      final entry = context.entry;
      final group = hashGroups[entry.hash];
      if (group == null ||
          reportedOffsets.contains(entry.offset) ||
          suppressedRanges.anyContainsStrictly(entry.range)) {
        continue;
      }

      final internalPartners = group
          .where(
            (c) =>
                c.entry.offset != entry.offset &&
                !suppressedRanges.anyContainsStrictly(c.entry.range),
          )
          .toList();
      final externalPartners =
          crossFileDuplicatesByHash[entry.hash] ?? const [];

      if (internalPartners.isEmpty && externalPartners.isEmpty) continue;

      _report(
        filePath: filePath,
        target: context,
        internalPartners: internalPartners,
        externalPartners: externalPartners,
      );

      reportedOffsets.add(entry.offset);
      suppressedRanges.add(entry.range);
    }
  }

  void _report({
    required String filePath,
    required DuplicateReportContext target,
    required List<DuplicateReportContext> internalPartners,
    required List<DuplicateLocation> externalPartners,
  }) {
    final currentEntry = target.entry;
    final internalEntries = internalPartners.map((p) => p.entry).toList();

    final hasExactPartner = _hasExactPartner(
      currentExactHash: currentEntry.exactHash,
      internalPartners: internalEntries,
      externalPartners: externalPartners,
    );

    final diagnosticCode = hasExactPartner
        ? _rule.exactCode
        : _rule.differentLiteralsCode;
    final isDifferentLiterals = diagnosticCode == _rule.differentLiteralsCode;

    final arguments = isDifferentLiterals
        ? [
            _computeLiteralsSummary(
              currentLiterals: target.collectLiterals(_literalsAnalyzer),
              partnerLiterals: [
                ...internalPartners.map(
                  (p) => p.collectLiterals(_literalsAnalyzer),
                ),
                ..._loadExternalLiterals(externalPartners),
              ],
            ),
          ]
        : const <String>[];

    final contextMessages = _buildContextMessages(
      currentFilePath: filePath,
      currentExactHash: currentEntry.exactHash,
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

  bool _hasExactPartner({
    required int currentExactHash,
    required Iterable<HashEntry> internalPartners,
    required List<DuplicateLocation> externalPartners,
  }) =>
      internalPartners.any((p) => p.exactHash == currentExactHash) ||
      externalPartners.any((p) => p.entry.exactHash == currentExactHash);

  Iterable<List<LiteralInfo>> _loadExternalLiterals(
    List<DuplicateLocation> locations,
  ) => locations
      .map(_literalsAnalyzer.loadExternalLiterals)
      .nonNulls
      .where((lits) => lits.isNotEmpty);

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
