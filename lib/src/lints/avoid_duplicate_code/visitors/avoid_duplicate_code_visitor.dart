import 'package:analyzer/dart/analysis/context_root.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/diagnostic/diagnostic.dart';
import 'package:analyzer/file_system/file_system.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/avoid_duplicate_code_rule.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/models/avoid_duplicate_code_parameters.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/models/body_candidate.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/models/duplicate_location.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/models/hash_entry.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/services/global_hash_registry.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/utils/context_root_extensions.dart';
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

  final AvoidDuplicateCodeRule _rule;
  final AvoidDuplicateCodeParameters _parameters;
  final String _filePath;
  final int _modificationStamp;
  final ContextRoot? _contextRoot;
  final ResourceProvider _resourceProvider;

  /// Creates a new instance of [AvoidDuplicateCodeVisitor].
  AvoidDuplicateCodeVisitor(
    this._rule,
    this._parameters, {
    required String filePath,
    required int modificationStamp,
    ContextRoot? contextRoot,
    ResourceProvider? resourceProvider,
  }) : _filePath = filePath,
       _modificationStamp = modificationStamp,
       _contextRoot = contextRoot,
       _resourceProvider =
           resourceProvider ?? PhysicalResourceProvider.INSTANCE;

  @override
  void visitCompilationUnit(CompilationUnit node) {
    final filePath = _filePath;
    if (filePath.isEmpty) return;

    GlobalHashRegistry.instance.resourceProvider = _resourceProvider;

    final packageRoot =
        _contextRoot?.root.path ?? _findPackageRoot(filePath) ?? '';

    if (_tryReportFromCache(filePath, packageRoot)) {
      return;
    }

    final candidates = _collectCandidates(node);

    final hasher = AstStructuralHashVisitor(
      ignoreLiterals: _parameters.ignoreLiterals,
      ignoreIdentifiers: _parameters.ignoreIdentifiers,
    );

    final hashEntries = <HashEntry>[];
    final candidateHashes = <AstNode, int>{};

    for (final candidate in candidates) {
      final hash = hasher.computeHash(candidate.node);
      candidateHashes[candidate.node] = hash;
      final line = node.lineInfo.getLocation(candidate.node.offset).lineNumber;
      hashEntries.add(
        HashEntry(
          hash: hash,
          lineNumber: line,
          offset: candidate.node.offset,
          length: candidate.node.length,
          tokenCount: candidate.node.tokenCount,
        ),
      );
    }

    final crossFileDuplicatesByHash = _findAndSaveCrossFileMatches(
      filePath,
      hashEntries,
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
      isFileExcluded: (p) => _contextRoot?.isFileExcluded(p) ?? false,
    );

    final hashGroups = <int, List<HashEntry>>{};
    for (final entry in cachedEntries) {
      (hashGroups[entry.hash] ??= []).add(entry);
    }

    final hasIntraDuplicates = hashGroups.values.any(
      (group) => group.length > 1,
    );
    final hasCrossDuplicates = crossMatches.isNotEmpty;

    if (!hasIntraDuplicates && !hasCrossDuplicates) {
      return true; // We checked the cache, and there are no duplicates.
    }

    final suppressedRanges = <(int, int)>[];
    final reportedOffsets = <int>{};

    final crossFileDuplicatesByHash = <int, List<DuplicateLocation>>{};
    for (final match in crossMatches) {
      crossFileDuplicatesByHash[match.currentEntry.hash] = match.duplicates;
    }

    for (final entry in cachedEntries) {
      final isSuppressed = suppressedRanges.any(
        (range) => (entry.offset, entry.length).isStrictlyWithin(range),
      );
      if (isSuppressed) continue;

      if (reportedOffsets.contains(entry.offset)) continue;

      final group = hashGroups[entry.hash];
      if (group == null) continue;

      final activeGroup = group.where((e) {
        return !suppressedRanges.any(
          (range) => (e.offset, e.length).isStrictlyWithin(range),
        );
      }).toList();

      final externalPartners =
          crossFileDuplicatesByHash[entry.hash] ?? const [];
      final internalPartners = activeGroup.where((e) => e != entry).toList();

      if (internalPartners.isNotEmpty || externalPartners.isNotEmpty) {
        final contextMessages = <DiagnosticMessage>[
          for (final dup in externalPartners)
            SolidDiagnosticMessage(
              filePath: dup.filePath,
              offset: dup.entry.offset,
              length: dup.entry.length,
              message: 'Duplicate',
            ),
          for (final other in internalPartners)
            SolidDiagnosticMessage(
              filePath: filePath,
              offset: other.offset,
              length: other.length,
              message: 'Duplicate',
            ),
        ];

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
    final crossFileDuplicatesByHash = <int, List<DuplicateLocation>>{};
    if (packageRoot.isEmpty) return crossFileDuplicatesByHash;

    final registry = GlobalHashRegistry.instance;
    final crossMatches = registry.findCrossFileMatches(
      filePath,
      hashEntries,
      parameters: _parameters,
      packageRoot: packageRoot,
      isFileExcluded: (p) => _contextRoot?.isFileExcluded(p) ?? false,
    );
    for (final match in crossMatches) {
      crossFileDuplicatesByHash[match.currentEntry.hash] = match.duplicates;
    }
    registry.updateFile(
      filePath,
      hashEntries,
      modificationStamp: _modificationStamp,
      parameters: _parameters,
      packageRoot: packageRoot,
    );

    return crossFileDuplicatesByHash;
  }

  void _groupAndReportDuplicates(
    String filePath,
    List<BodyCandidate> candidates,
    Map<AstNode, int> candidateHashes,
    AstStructuralHashVisitor hasher,
    Map<int, List<DuplicateLocation>> crossFileDuplicatesByHash,
  ) {
    final groups = <int, List<BodyCandidate>>{};
    for (final candidate in candidates) {
      final hash =
          candidateHashes[candidate.node] ?? hasher.computeHash(candidate.node);
      (groups[hash] ??= []).add(candidate);
    }

    final suppressed = <AstNode>{};
    final reported = <AstNode>{};

    for (final candidate in candidates) {
      if (suppressed.contains(candidate.node)) continue;
      if (reported.contains(candidate.node)) continue;

      final hash =
          candidateHashes[candidate.node] ?? hasher.computeHash(candidate.node);
      final group = groups[hash];
      if (group == null) continue;

      final activeGroup = group
          .where((c) => !suppressed.contains(c.node))
          .toList();

      final externalPartners = crossFileDuplicatesByHash[hash] ?? const [];
      final internalPartners = activeGroup
          .where((c) => c != candidate)
          .toList();

      if (internalPartners.isNotEmpty || externalPartners.isNotEmpty) {
        final contextMessages = <DiagnosticMessage>[
          for (final dup in externalPartners)
            SolidDiagnosticMessage(
              filePath: dup.filePath,
              offset: dup.entry.offset,
              length: dup.entry.length,
              message: _duplicateContextMessage,
            ),
          for (final other in internalPartners)
            SolidDiagnosticMessage(
              filePath: filePath,
              offset: other.node.offset,
              length: other.node.length,
              message: _duplicateContextMessage,
            ),
        ];

        _rule.reportAtNode(
          candidate.node,
          contextMessages: contextMessages,
        );

        reported.add(candidate.node);
        _suppressDescendants(candidate.node, suppressed);
      }
    }
  }

  void _suppressDescendants(AstNode root, Set<AstNode> suppressed) {
    final descendantCollector = DescendantVisitor(suppressed, root);
    root.accept(descendantCollector);
  }

  static final _packageRootCache = <String, String?>{};

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
