import 'package:analyzer/dart/analysis/context_root.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/file_system/file_system.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:collection/collection.dart';
import 'package:solid_lints/src/common/parameter_parser/analysis_options_loader.dart';
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
import 'package:solid_lints/src/lints/avoid_duplicate_code/utils/token_utils.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/visitors/ast_structural_hash_visitor.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/visitors/candidate_visitor.dart';
import 'package:solid_lints/src/utils/ignore_matcher.dart';

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
  final AnalysisOptionsLoader? _analysisOptionsLoader;
  final IgnoreMatcher _ignoreMatcher;

  /// Creates a new instance of [AvoidDuplicateCodeVisitor].
  factory AvoidDuplicateCodeVisitor(
    AvoidDuplicateCodeRule rule,
    AvoidDuplicateCodeParameters parameters, {
    required String filePath,
    required int modificationStamp,
    required IgnoreMatcher ignoreMatcher,
    ContextRoot? contextRoot,
    ResourceProvider? resourceProvider,
    AnalysisOptionsLoader? analysisOptionsLoader,
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
      analysisOptionsLoader: analysisOptionsLoader,
      ignoreMatcher: ignoreMatcher,
    );
  }

  AvoidDuplicateCodeVisitor._({
    required this._parameters,
    required this._filePath,
    required this._modificationStamp,
    required this._contextRoot,
    required this._resourceProvider,
    required this._reporter,
    required this._analysisOptionsLoader,
    required this._ignoreMatcher,
  });

  @override
  void visitCompilationUnit(CompilationUnit node) {
    if (_filePath.isEmpty) return;
    final filePath = _filePath;

    final packageRoot =
        _contextRoot?.root.path ??
        GlobalHashRegistry.instance.findPackageRoot(
          filePath,
          resourceProvider: _resourceProvider,
        ) ??
        '';

    final isExcluded =
        _analysisOptionsLoader?.isFileExcludedForFile(filePath) ?? false;

    if (isExcluded || _ignoreMatcher.isFileIgnored(node)) {
      GlobalHashRegistry.instance.removeFile(
        filePath,
        resourceProvider: _resourceProvider,
        parameters: _parameters,
        packageRoot: packageRoot,
      );
      return;
    }

    if (_tryReportFromCache(filePath, packageRoot)) return;

    final rawCandidates = _collectCandidates(node);
    final candidates = _analyzeCandidates(node, rawCandidates);

    final crossFileDuplicatesByHash = _findAndSaveCrossFileMatches(
      filePath,
      candidates.map((c) => c.entry).toList(),
      packageRoot,
    );

    if (candidates.isEmpty) return;

    _reporter.report(
      filePath: filePath,
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

  List<BodyCandidate> _collectCandidates(CompilationUnit node) {
    final collector = CandidateVisitor(_parameters);
    node.accept(collector);
    return collector.candidates
        .whereNot(
          (c) => _ignoreMatcher.isCandidateIgnored(
            c.node,
            c.enclosingDeclaration,
          ),
        )
        .toList();
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
      isFileExcluded: _isFileExcluded,
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

  bool _isFileExcluded(String path) =>
      _analysisOptionsLoader?.isFileExcludedForFile(path) ?? false;

  Map<int, List<DuplicateLocation>> _findAndSaveCrossFileMatches(
    String filePath,
    List<HashEntry> hashEntries,
    String packageRoot,
  ) {
    final registry = GlobalHashRegistry.instance;
    final crossMatches = registry.findCrossFileMatches(
      filePath,
      hashEntries,
      resourceProvider: _resourceProvider,
      parameters: _parameters,
      packageRoot: packageRoot,
      isFileExcluded: _isFileExcluded,
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
