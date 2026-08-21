import 'package:analyzer/dart/analysis/context_root.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/file_system/file_system.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/avoid_duplicate_code_rule.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/models/analyzed_candidate.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/models/avoid_duplicate_code_parameters.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/models/body_candidate.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/models/cross_file_match.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/models/duplicate_location.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/models/hash_entry.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/reporters/avoid_duplicate_code_reporter.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/reporters/duplicate_report_context.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/services/differing_literals_analyzer.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/services/global_hash_registry.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/utils/context_root_extensions.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/utils/token_utils.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/visitors/ast_structural_hash_visitor.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/visitors/candidate_visitor.dart';

/// A visitor that detects duplicate code blocks (at the function level and/or
/// statement block level) within a single compilation unit and across files,
/// differentiating between exact duplicates and duplicates with differing
/// literal values.
class AvoidDuplicateCodeVisitor extends RecursiveAstVisitor<void> {
  final AvoidDuplicateCodeParameters _parameters;
  final String _filePath;
  final int _modificationStamp;
  final ContextRoot? _contextRoot;
  final ResourceProvider _resourceProvider;
  final AvoidDuplicateCodeReporter _reporter;

  /// Creates a new instance of [AvoidDuplicateCodeVisitor].
  factory AvoidDuplicateCodeVisitor(
    AvoidDuplicateCodeRule rule,
    AvoidDuplicateCodeParameters parameters, {
    required String filePath,
    required int modificationStamp,
    ContextRoot? contextRoot,
    ResourceProvider? resourceProvider,
  }) {
    final effectiveResourceProvider =
        resourceProvider ?? PhysicalResourceProvider.INSTANCE;
    final reporter = AvoidDuplicateCodeReporter(
      rule: rule,
      literalsAnalyzer: DifferingLiteralsAnalyzer(
        resourceProvider: effectiveResourceProvider,
      ),
    );

    return AvoidDuplicateCodeVisitor._(
      parameters: parameters,
      filePath: filePath,
      modificationStamp: modificationStamp,
      contextRoot: contextRoot,
      resourceProvider: effectiveResourceProvider,
      reporter: reporter,
    );
  }

  AvoidDuplicateCodeVisitor._({
    required AvoidDuplicateCodeParameters parameters,
    required String filePath,
    required int modificationStamp,
    required ContextRoot? contextRoot,
    required ResourceProvider resourceProvider,
    required AvoidDuplicateCodeReporter reporter,
  }) : _parameters = parameters,
       _filePath = filePath,
       _modificationStamp = modificationStamp,
       _contextRoot = contextRoot,
       _resourceProvider = resourceProvider,
       _reporter = reporter;

  @override
  void visitCompilationUnit(CompilationUnit node) {
    if (_filePath.isEmpty) return;
    final packageRoot =
        _contextRoot?.root.path ??
        GlobalHashRegistry.instance.findPackageRoot(
          _filePath,
          resourceProvider: _resourceProvider,
        ) ??
        '';

    if (_tryReportFromCache(_filePath, packageRoot)) return;

    final rawCandidates = _collectCandidates(node);
    if (rawCandidates.isEmpty) return;

    final candidates = _analyzeCandidates(node, rawCandidates);

    final crossFileDuplicatesByHash = _findAndSaveCrossFileMatches(
      _filePath,
      candidates.map((c) => c.entry).toList(),
      packageRoot,
    );

    _reporter.report(
      filePath: _filePath,
      contexts: DuplicateReportContext.fromAstCandidates(candidates),
      crossFileDuplicatesByHash: crossFileDuplicatesByHash,
    );
  }

  List<AnalyzedCandidate> _analyzeCandidates(
    CompilationUnit unit,
    List<BodyCandidate> candidates,
  ) {
    final hasher = AstStructuralHashVisitor();

    return candidates.map((candidate) {
      final candidateNode = candidate.node;
      final hashes = hasher.computeHashes(candidateNode);
      final lineInfo = unit.lineInfo.getLocation(candidateNode.offset);

      return (
        candidate: candidate,
        entry: HashEntry(
          hash: hashes.structuralHash,
          exactHash: hashes.exactHash,
          lineNumber: lineInfo.lineNumber,
          offset: candidateNode.offset,
          length: candidateNode.length,
          tokenCount: candidateNode.tokenCount,
        ),
      );
    }).toList();
  }

  bool _tryReportFromCache(String filePath, String packageRoot) {
    if (packageRoot.isEmpty) return false;

    final registry = GlobalHashRegistry.instance;
    final cachedStamp = registry.getModificationStamp(
      filePath,
      resourceProvider: _resourceProvider,
      parameters: _parameters,
      packageRoot: packageRoot,
    );

    if (cachedStamp == null || cachedStamp != _modificationStamp) return false;

    final cachedEntries = registry.getFileEntries(
      filePath,
      resourceProvider: _resourceProvider,
      parameters: _parameters,
      packageRoot: packageRoot,
    );

    if (cachedEntries == null) return false;

    final crossMatches = registry.findCrossFileMatches(
      filePath,
      cachedEntries,
      resourceProvider: _resourceProvider,
      parameters: _parameters,
      packageRoot: packageRoot,
      isFileExcluded: (p) => _contextRoot?.isFileExcluded(p) ?? false,
    );

    _reporter.report(
      filePath: filePath,
      contexts: DuplicateReportContext.fromCachedEntries(
        cachedEntries,
        filePath: filePath,
      ),
      crossFileDuplicatesByHash: crossMatches.toDuplicatesByHash(),
    );

    return true;
  }

  List<BodyCandidate> _collectCandidates(CompilationUnit node) {
    final collector = CandidateVisitor(_parameters);
    node.accept(collector);
    return collector.candidates;
  }

  Map<int, List<DuplicateLocation>> _findAndSaveCrossFileMatches(
    String filePath,
    List<HashEntry> hashEntries,
    String packageRoot,
  ) {
    if (packageRoot.isEmpty) return const {};

    final registry = GlobalHashRegistry.instance;
    final crossMatches = registry.findCrossFileMatches(
      filePath,
      hashEntries,
      resourceProvider: _resourceProvider,
      parameters: _parameters,
      packageRoot: packageRoot,
      isFileExcluded: (p) => _contextRoot?.isFileExcluded(p) ?? false,
    );
    registry.updateFile(
      filePath,
      hashEntries,
      modificationStamp: _modificationStamp,
      resourceProvider: _resourceProvider,
      parameters: _parameters,
      packageRoot: packageRoot,
    );

    return crossMatches.toDuplicatesByHash();
  }
}
