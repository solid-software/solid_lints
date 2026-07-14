import 'dart:io';

import 'package:analyzer/dart/analysis/context_root.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/diagnostic/diagnostic.dart';
import 'package:path/path.dart' as path;
import 'package:solid_lints/src/lints/avoid_duplicate_code/avoid_duplicate_code_rule.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/models/avoid_duplicate_code_parameters.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/models/cross_file_match.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/models/hash_entry.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/services/global_hash_registry.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/visitors/ast_structural_hasher.dart';
import 'package:solid_lints/src/models/solid_diagnostic_message.dart';

extension _RangeExtension on (int, int) {
  bool isStrictlyWithin((int, int) parent) {
    return this.$1 >= parent.$1 &&
        (this.$1 + this.$2) <= (parent.$1 + parent.$2) &&
        !(this.$1 == parent.$1 && this.$2 == parent.$2);
  }
}

/// A record representing a block or expression candidate for clone detection.
typedef _BodyCandidate = ({
  AstNode node,
  Declaration? enclosingDeclaration,
});

/// A visitor that detects duplicate code blocks (at the function level and/or
/// statement block level) within a single compilation unit and across files.
class AvoidDuplicateCodeVisitor extends RecursiveAstVisitor<void> {
  final AvoidDuplicateCodeRule _rule;
  final AvoidDuplicateCodeParameters _parameters;
  final String _filePath;
  final int _modificationStamp;
  final ContextRoot? _contextRoot;

  /// Creates a new instance of [AvoidDuplicateCodeVisitor].
  AvoidDuplicateCodeVisitor(
    this._rule,
    this._parameters, {
    required String filePath,
    required int modificationStamp,
    ContextRoot? contextRoot,
  }) : _filePath = filePath,
       _modificationStamp = modificationStamp,
       _contextRoot = contextRoot;

  @override
  void visitCompilationUnit(CompilationUnit node) {
    final filePath = _filePath;
    if (filePath.isEmpty) return;

    final packageRoot =
        _contextRoot?.root.path ?? _findPackageRoot(filePath) ?? '';

    if (_tryReportFromCache(filePath, packageRoot)) {
      return;
    }

    final candidates = _collectCandidates(node);

    final hasher = AstStructuralHasher(
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
          tokenCount: _tokenCount(candidate.node),
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
      isFileExcluded: _isFileExcluded,
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

  bool _isFileExcluded(String otherPath) {
    final contextRoot = _contextRoot;
    if (contextRoot == null) return false;
    final isWithin = otherPath.startsWith(contextRoot.root.path);
    return isWithin && !contextRoot.isAnalyzed(otherPath);
  }

  List<_BodyCandidate> _collectCandidates(CompilationUnit node) {
    final collector = _CandidateCollector(_parameters);
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
      isFileExcluded: _isFileExcluded,
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
    List<_BodyCandidate> candidates,
    Map<AstNode, int> candidateHashes,
    AstStructuralHasher hasher,
    Map<int, List<DuplicateLocation>> crossFileDuplicatesByHash,
  ) {
    final groups = <int, List<_BodyCandidate>>{};
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
              message: 'Duplicate',
            ),
          for (final other in internalPartners)
            SolidDiagnosticMessage(
              filePath: filePath,
              offset: other.node.offset,
              length: other.node.length,
              message: 'Duplicate',
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

  static int _tokenCount(AstNode node) {
    int count = 0;
    var token = node.beginToken;
    final end = node.endToken;
    while (token != end) {
      count++;
      token = token.next!;
    }
    return count + 1;
  }

  void _suppressDescendants(AstNode root, Set<AstNode> suppressed) {
    root.accept(_DescendantCollector(suppressed, root));
  }

  static final _packageRootCache = <String, String?>{};

  String? _findPackageRoot(String filePath) {
    if (filePath.isEmpty) return null;
    final dirPath = path.dirname(filePath);
    return _packageRootCache.putIfAbsent(dirPath, () {
      var dir = Directory(dirPath);
      while (true) {
        final pubspec = File(path.join(dir.path, 'pubspec.yaml'));
        if (pubspec.existsSync()) {
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

/// A visitor that collects descendant candidate blocks to suppress them.
class _DescendantCollector extends RecursiveAstVisitor<void> {
  final Set<AstNode> suppressed;
  final AstNode root;

  _DescendantCollector(this.suppressed, this.root);

  @override
  void visitBlock(Block node) {
    if (node != root) {
      suppressed.add(node);
    }
    super.visitBlock(node);
  }

  @override
  void visitExpressionFunctionBody(ExpressionFunctionBody node) {
    if (node != root) {
      suppressed.add(node);
    }
    super.visitExpressionFunctionBody(node);
  }
}

class _CandidateCollector extends RecursiveAstVisitor<void> {
  final List<_BodyCandidate> candidates = [];
  final AvoidDuplicateCodeParameters parameters;

  _CandidateCollector(this.parameters);

  @override
  void visitBlock(Block node) {
    // If checkBlocks is false, only consider blocks that represent function
    // bodies.
    if (!parameters.checkBlocks && node.parent is! BlockFunctionBody) {
      super.visitBlock(node);
      return;
    }

    _checkAndCollect(node, AvoidDuplicateCodeVisitor._tokenCount(node));
    super.visitBlock(node);
  }

  @override
  void visitExpressionFunctionBody(ExpressionFunctionBody node) {
    _checkAndCollect(node, AvoidDuplicateCodeVisitor._tokenCount(node));
    super.visitExpressionFunctionBody(node);
  }

  void _checkAndCollect(AstNode node, int tokenCount) {
    if (tokenCount < parameters.minTokens) return;

    final declaration = node.thisOrAncestorOfType<Declaration>();
    if (declaration != null && parameters.exclude.shouldIgnore(declaration)) {
      return;
    }

    candidates.add((
      node: node,
      enclosingDeclaration: declaration,
    ));
  }
}
