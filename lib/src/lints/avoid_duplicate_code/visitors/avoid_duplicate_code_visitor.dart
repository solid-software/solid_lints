import 'package:analyzer/dart/analysis/context_root.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/diagnostic/diagnostic.dart';
import 'package:analyzer/file_system/file_system.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:collection/collection.dart';
import 'package:solid_lints/src/common/parameter_parser/analysis_options_loader.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/avoid_duplicate_code_rule.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/models/avoid_duplicate_code_parameters.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/models/body_candidate.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/models/cross_file_match.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/models/duplicate_location.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/models/hash_entry.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/services/global_hash_registry.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/utils/ignore_matcher.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/utils/range_extension.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/utils/token_utils.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/visitors/ast_structural_hash_visitor.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/visitors/candidate_visitor.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/visitors/descendant_visitor.dart';
import 'package:solid_lints/src/models/solid_diagnostic_message.dart';

/// A visitor that detects duplicate code blocks (at the function level and/or
/// statement block level) within a single compilation unit and across files.
class AvoidDuplicateCodeVisitor extends RecursiveAstVisitor<void> {
  static const _duplicateContextMessage = 'Duplicate';
  static final _packageRootCache = <String, String?>{};

  final AvoidDuplicateCodeRule _rule;
  final AvoidDuplicateCodeParameters _parameters;
  final String _filePath;
  final int _modificationStamp;
  final ContextRoot? _contextRoot;
  final ResourceProvider _resourceProvider;
  final AnalysisOptionsLoader? _analysisOptionsLoader;

  /// Creates a new instance of [AvoidDuplicateCodeVisitor].
  AvoidDuplicateCodeVisitor(
    this._rule,
    this._parameters, {
    required String filePath,
    required int modificationStamp,
    ContextRoot? contextRoot,
    ResourceProvider? resourceProvider,
    AnalysisOptionsLoader? analysisOptionsLoader,
  }) : _filePath = filePath,
       _modificationStamp = modificationStamp,
       _contextRoot = contextRoot,
       _resourceProvider =
           resourceProvider ?? PhysicalResourceProvider.INSTANCE,
       _analysisOptionsLoader = analysisOptionsLoader;

  @override
  void visitCompilationUnit(CompilationUnit node) {
    if (_filePath.isEmpty) return;
    final filePath = _filePath;

    GlobalHashRegistry.instance.resourceProvider = _resourceProvider;
    final packageRoot =
        _contextRoot?.root.path ?? _findPackageRoot(filePath) ?? '';

    if (_analysisOptionsLoader?.isFileExcludedForFile(filePath) ?? false) {
      GlobalHashRegistry.instance.removeFile(
        filePath,
        parameters: _parameters,
        packageRoot: packageRoot,
      );
      return;
    }

    if (IgnoreMatcher.isFileIgnored(node)) {
      GlobalHashRegistry.instance.removeFile(
        filePath,
        parameters: _parameters,
        packageRoot: packageRoot,
      );
      return;
    }

    if (_tryReportFromCache(filePath, packageRoot)) {
      return;
    }
    final hasher = AstStructuralHashVisitor(
      ignoreLiterals: _parameters.ignoreLiterals,
      ignoreIdentifiers: _parameters.ignoreIdentifiers,
    );
    final candidates = _collectCandidates(node);
    final candidateHashes = {
      for (final BodyCandidate(:node) in candidates)
        node: hasher.computeHash(node),
    };
    final crossFileDuplicatesByHash = _findAndSaveCrossFileMatches(
      filePath,
      candidates
          .map(
            (c) => HashEntry(
              hash: candidateHashes[c.node]!,
              lineNumber: node.lineInfo.getLocation(c.node.offset).lineNumber,
              offset: c.node.offset,
              length: c.node.length,
              tokenCount: c.node.tokenCount,
            ),
          )
          .toList(),
      packageRoot,
    );
    _groupAndReportDuplicates(
      filePath,
      candidates,
      candidateHashes,
      hasher,
      crossFileDuplicatesByHash,
    );
  }

  List<BodyCandidate> _collectCandidates(CompilationUnit node) {
    final collector = CandidateVisitor(_parameters);
    node.accept(collector);
    return collector.candidates
        .where(
          (c) => !IgnoreMatcher.isCandidateIgnored(
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
      parameters: _parameters,
      packageRoot: packageRoot,
    );

    if (cachedStamp != _modificationStamp) return false;

    final cachedEntries = registry.getFileEntries(
      filePath,
      parameters: _parameters,
      packageRoot: packageRoot,
    );
    if (cachedEntries == null) return false;

    final crossMatches = registry.findCrossFileMatches(
      filePath,
      cachedEntries,
      parameters: _parameters,
      packageRoot: packageRoot,
      isFileExcluded: _isFileExcluded,
    );

    final hashGroups = groupBy(cachedEntries, (entry) => entry.hash);

    final hasIntraDuplicates = hashGroups.values.any(
      (group) => group.length > 1,
    );
    final hasCrossDuplicates = crossMatches.isNotEmpty;

    if (!hasIntraDuplicates && !hasCrossDuplicates) {
      return true; // We checked the cache, and there are no duplicates.
    }

    final suppressedRanges = <(int, int)>[];
    final reportedOffsets = <int>{};

    final crossFileDuplicatesByHash = crossMatches.toDuplicatesByHash();

    for (final entry in cachedEntries) {
      final group = hashGroups[entry.hash];
      if (suppressedRanges.anyContainsStrictly(entry.range) ||
          reportedOffsets.contains(entry.offset) ||
          group == null) {
        continue;
      }

      final activeGroup = group
          .where((e) => !suppressedRanges.anyContainsStrictly(e.range))
          .toList();

      final externalPartners =
          crossFileDuplicatesByHash[entry.hash] ?? const [];
      final internalPartners = activeGroup.where((e) => e != entry).toList();

      if (internalPartners.isNotEmpty || externalPartners.isNotEmpty) {
        final contextMessages = _buildContextMessages(
          currentFilePath: filePath,
          externalPartners: externalPartners,
          internalPartners: internalPartners.map((e) => (e.offset, e.length)),
        );

        _rule.reportAtOffset(
          entry.offset,
          entry.length,
          contextMessages: contextMessages,
        );

        reportedOffsets.add(entry.offset);
        suppressedRanges.add((entry.offset, entry.length));
      }
    }

    return true; // Cache hit and handled
  }

  bool _isFileExcluded(String path) =>
      _analysisOptionsLoader?.isFileExcludedForFile(path) ?? false;

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
      parameters: _parameters,
      packageRoot: packageRoot,
      isFileExcluded: _isFileExcluded,
    );

    registry.updateFile(
      filePath,
      hashEntries,
      modificationStamp: _modificationStamp,
      parameters: _parameters,
      packageRoot: packageRoot,
    );

    return crossMatches.toDuplicatesByHash();
  }

  void _groupAndReportDuplicates(
    String filePath,
    List<BodyCandidate> candidates,
    Map<AstNode, int> candidateHashes,
    AstStructuralHashVisitor hasher,
    Map<int, List<DuplicateLocation>> crossFileDuplicatesByHash,
  ) {
    final groups = groupBy(
      candidates,
      (c) => candidateHashes[c.node] ?? hasher.computeHash(c.node),
    );

    final suppressed = <AstNode>{};

    for (final candidate in candidates.toSet()) {
      // Skip candidates that are descendants of an already reported duplicate
      // block to prevent nested warnings.
      if (suppressed.contains(candidate.node)) continue;

      final hash =
          candidateHashes[candidate.node] ?? hasher.computeHash(candidate.node);
      final internalPartners = groups[hash]?.toList();
      if (internalPartners == null) continue;

      final externalPartners = crossFileDuplicatesByHash[hash] ?? const [];
      internalPartners
        ..removeWhere((c) => suppressed.contains(c.node))
        ..remove(candidate);

      if (internalPartners.isEmpty && externalPartners.isEmpty) continue;

      _rule.reportAtNode(
        candidate.node,
        contextMessages: _buildContextMessages(
          currentFilePath: filePath,
          externalPartners: externalPartners,
          internalPartners: internalPartners.map(
            (c) => (c.node.offset, c.node.length),
          ),
        ),
      );

      _suppressDescendants(candidate.node, suppressed);
    }
  }

  void _suppressDescendants(AstNode root, Set<AstNode> suppressed) {
    final descendantCollector = DescendantVisitor(suppressed, root);
    root.accept(descendantCollector);
  }

  List<DiagnosticMessage> _buildContextMessages({
    required String currentFilePath,
    required List<DuplicateLocation> externalPartners,
    required Iterable<(int offset, int length)> internalPartners,
  }) {
    return [
      for (final dup in externalPartners)
        SolidDiagnosticMessage(
          filePath: dup.filePath,
          offset: dup.entry.offset,
          length: dup.entry.length,
          message: _duplicateContextMessage,
        ),
      for (final (offset, length) in internalPartners)
        SolidDiagnosticMessage(
          filePath: currentFilePath,
          offset: offset,
          length: length,
          message: _duplicateContextMessage,
        ),
    ];
  }

  /// Clears the cached package root lookups. Should be called when
  /// the registry is cleared to avoid stale project path references.
  static void clearPackageRootCache() => _packageRootCache.clear();

  String? _findPackageRoot(String filePath) {
    if (filePath.isEmpty) return null;
    final pathContext = _resourceProvider.pathContext;
    final dirPath = pathContext.dirname(filePath);
    return _packageRootCache.putIfAbsent(dirPath, () {
      var dir = _resourceProvider.getFolder(dirPath);
      while (true) {
        final pubspec = dir.getChildAssumingFile('pubspec.yaml');
        if (pubspec.exists) {
          return dir.path;
        }
        final parent = dir.parent;
        if (parent.path == dir.path) {
          break;
        }
        dir = parent;
      }
      return null;
    });
  }
}
