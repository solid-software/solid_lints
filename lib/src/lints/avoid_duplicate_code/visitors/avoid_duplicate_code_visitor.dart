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

    // --- Phase 0: Try to use cached entries if file is unchanged and has no
    // warnings
    if (filePath.isNotEmpty) {
      final contextRoot = _contextRoot;
      final packageRoot =
          contextRoot?.root.path ?? _findPackageRoot(filePath) ?? '';
      if (packageRoot.isNotEmpty) {
        final registry = GlobalHashRegistry.instance;
        final cachedStamp = registry.getModificationStamp(
          filePath,
          parameters: _parameters,
          packageRoot: packageRoot,
        );

        if (cachedStamp == _modificationStamp) {
          final cachedEntries = registry.getFileEntries(
            filePath,
            parameters: _parameters,
            packageRoot: packageRoot,
          );
          if (cachedEntries != null) {
            // Check if there are any cross-file matches
            final crossMatches = registry.findCrossFileMatches(
              filePath,
              cachedEntries,
              parameters: _parameters,
              packageRoot: packageRoot,
              isFileExcluded: (otherPath) {
                if (contextRoot == null) return false;
                final isWithin = otherPath.startsWith(contextRoot.root.path);
                return isWithin && !contextRoot.isAnalyzed(otherPath);
              },
            );

            // Check if there are any intra-file duplicates
            final hashGroups = <int, List<HashEntry>>{};
            for (final entry in cachedEntries) {
              (hashGroups[entry.hash] ??= []).add(entry);
            }

            final hasIntraDuplicates = hashGroups.values.any(
              (group) => group.length > 1,
            );
            final hasCrossDuplicates = crossMatches.isNotEmpty;

            if (!hasIntraDuplicates && !hasCrossDuplicates) {
              return;
            }

            // We have warnings, but we can report them directly from the cache!

            final suppressedRanges = <(int offset, int length)>[];
            final reportedOffsets = <int>{};

            final crossFileDuplicatesByHash = <int, List<DuplicateLocation>>{};
            for (final match in crossMatches) {
              crossFileDuplicatesByHash[match.currentEntry.hash] =
                  match.duplicates;
            }

            for (final entry in cachedEntries) {
              // Check if suppressed
              final isSuppressed = suppressedRanges.any(
                (range) =>
                    entry.offset >= range.$1 &&
                    (entry.offset + entry.length) <= (range.$1 + range.$2),
              );
              if (isSuppressed) continue;

              // Also check if we already reported this exact entry
              if (reportedOffsets.contains(entry.offset)) continue;

              final group = hashGroups[entry.hash];
              if (group == null) continue;

              final activeGroup = group.where((e) {
                return !suppressedRanges.any(
                  (range) =>
                      e.offset >= range.$1 &&
                      (e.offset + e.length) <= (range.$1 + range.$2),
                );
              }).toList();

              final externalPartners =
                  crossFileDuplicatesByHash[entry.hash] ?? const [];
              final internalPartners = activeGroup
                  .where((e) => e != entry)
                  .toList();

              final shouldReport =
                  internalPartners.isNotEmpty || externalPartners.isNotEmpty;

              if (shouldReport) {
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

            return;
          }
        }
      }
    }

    final collector = _CandidateCollector(_parameters);
    node.accept(collector);
    final candidates = collector.candidates;

    final hasher = AstStructuralHasher(
      ignoreLiterals: _parameters.ignoreLiterals,
      ignoreIdentifiers: _parameters.ignoreIdentifiers,
    );

    // --- Phase A: Build hash entries for cross-file registry ---
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

    // --- Phase B: Find Cross-file matches from registry ---
    final crossFileDuplicatesByHash = <int, List<DuplicateLocation>>{};
    if (filePath.isNotEmpty) {
      final contextRoot = _contextRoot;
      final packageRoot =
          contextRoot?.root.path ?? _findPackageRoot(filePath) ?? '';

      final registry = GlobalHashRegistry.instance;
      final crossMatches = registry.findCrossFileMatches(
        filePath,
        hashEntries,
        parameters: _parameters,
        packageRoot: packageRoot,
        isFileExcluded: (otherPath) {
          if (contextRoot == null) return false;
          final isWithin = otherPath.startsWith(contextRoot.root.path);
          return isWithin && !contextRoot.isAnalyzed(otherPath);
        },
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
    }

    // --- Phase C: Group candidates by structural hash for intra-file ---
    final groups = <int, List<_BodyCandidate>>{};
    for (final candidate in candidates) {
      final hash =
          candidateHashes[candidate.node] ?? hasher.computeHash(candidate.node);
      (groups[hash] ??= []).add(candidate);
    }

    final suppressed = <AstNode>{};
    final reported = <AstNode>{};

    // Candidates are collected pre-order (parent before children).
    // Process larger scopes first, and suppress warnings on children.
    for (final candidate in candidates) {
      if (suppressed.contains(candidate.node)) continue;
      if (reported.contains(candidate.node)) continue;

      final hash =
          candidateHashes[candidate.node] ?? hasher.computeHash(candidate.node);
      final group = groups[hash];
      if (group == null) continue;

      // Filter group to only include non-suppressed candidates
      final activeGroup = group
          .where((c) => !suppressed.contains(c.node))
          .toList();

      final externalPartners = crossFileDuplicatesByHash[hash] ?? const [];
      final internalPartners = activeGroup
          .where((c) => c != candidate)
          .toList();

      final hasExternalDuplicates = externalPartners.isNotEmpty;
      final hasInternalDuplicates = internalPartners.isNotEmpty;

      // Report a warning if there are any duplicates (internal or external)
      final shouldReport = hasInternalDuplicates || hasExternalDuplicates;

      if (shouldReport) {
        final contextMessages = <DiagnosticMessage>[
          // Add external partners
          for (final dup in externalPartners)
            SolidDiagnosticMessage(
              filePath: dup.filePath,
              offset: dup.entry.offset,
              length: dup.entry.length,
              message: 'Duplicate',
            ),
          // Add internal partners
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

        // Mark this duplicate block as reported.
        reported.add(candidate.node);
        // Mark all its descendants as suppressed.
        _suppressDescendants(candidate.node, suppressed);
      }
    }
  }

  /// Returns the number of tokens in a body node.
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

  String? _findPackageRoot(String filePath) {
    if (filePath.isEmpty) return null;
    var dir = File(filePath).parent;
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
