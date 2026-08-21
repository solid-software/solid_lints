import 'package:analyzer/diagnostic/diagnostic.dart';
import 'package:analyzer/error/error.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/avoid_duplicate_code_rule.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/models/analyzed_candidate.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/models/duplicate_location.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/models/hash_entry.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/models/literal_info.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/services/differing_literals_analyzer.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/visitors/literal_collector_visitor.dart';

/// Encapsulates reporting and literal extraction for duplicate code candidates.
class DuplicateReportContext {
  /// The [HashEntry] associated with this duplicate candidate.
  final HashEntry entry;

  final List<LiteralInfo> Function(DifferingLiteralsAnalyzer) _literalsProvider;

  DuplicateReportContext._({
    required this.entry,
    required List<LiteralInfo> Function(DifferingLiteralsAnalyzer)
    literalsProvider,
  }) : _literalsProvider = literalsProvider;

  /// Creates a list of contexts from analyzed AST [candidates].
  static List<DuplicateReportContext> fromAstCandidates(
    List<AnalyzedCandidate> candidates,
  ) => candidates
      .map(
        (candidate) => DuplicateReportContext._(
          entry: candidate.entry,
          literalsProvider: (_) => LiteralCollectorVisitor.collect(
            candidate.candidate.node,
          ),
        ),
      )
      .toList();

  /// Creates a list of contexts from [cachedEntries].
  static List<DuplicateReportContext> fromCachedEntries(
    List<HashEntry> cachedEntries, {
    required String filePath,
  }) => cachedEntries
      .map(
        (entry) => DuplicateReportContext._(
          entry: entry,
          literalsProvider: (literalsAnalyzer) =>
              literalsAnalyzer.loadExternalLiterals(
                DuplicateLocation(filePath: filePath, entry: entry),
              ) ??
              const [],
        ),
      )
      .toList();

  /// Collects literal values present in this duplicate candidate using the
  /// provided [literalsAnalyzer].
  List<LiteralInfo> collectLiterals(
    DifferingLiteralsAnalyzer literalsAnalyzer,
  ) => _literalsProvider(literalsAnalyzer);

  /// Reports a diagnostic lint on this candidate using the provided [rule].
  void report(
    AvoidDuplicateCodeRule rule, {
    required DiagnosticCode diagnosticCode,
    required List<String> arguments,
    required List<DiagnosticMessage> contextMessages,
  }) {
    rule.reportAtOffset(
      entry.offset,
      entry.length,
      diagnosticCode: diagnosticCode,
      arguments: arguments,
      contextMessages: contextMessages,
    );
  }
}
