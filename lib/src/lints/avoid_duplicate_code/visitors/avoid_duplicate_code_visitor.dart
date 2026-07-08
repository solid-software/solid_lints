import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/avoid_duplicate_code_rule.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/models/avoid_duplicate_code_parameters.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/visitors/ast_structural_hasher.dart';

/// A record representing a block or expression candidate for clone detection.
typedef _BodyCandidate = ({
  AstNode node,
  Declaration? enclosingDeclaration,
});

/// A visitor that detects duplicate code blocks (at the function level and/or
/// statement block level) within a single compilation unit.
class AvoidDuplicateCodeVisitor extends RecursiveAstVisitor<void> {
  final AvoidDuplicateCodeRule _rule;
  final AvoidDuplicateCodeParameters _parameters;

  /// Creates a new instance of [AvoidDuplicateCodeVisitor].
  AvoidDuplicateCodeVisitor(this._rule, this._parameters);

  @override
  void visitCompilationUnit(CompilationUnit node) {
    final collector = _CandidateCollector(_parameters);
    node.accept(collector);

    final candidates = collector.candidates;
    if (candidates.length < 2) return;

    final hasher = AstStructuralHasher(
      ignoreLiterals: _parameters.ignoreLiterals,
      ignoreIdentifiers: _parameters.ignoreIdentifiers,
    );

    // Group candidates by their structural hash
    final groups = <int, List<_BodyCandidate>>{};
    for (final candidate in candidates) {
      final hash = hasher.computeHash(candidate.node);
      (groups[hash] ??= []).add(candidate);
    }

    final lineInfo = node.lineInfo;
    final suppressed = <AstNode>{};

    // Candidates are collected pre-order (parent before children).
    // By iterating in this order, we can process larger scopes first,
    // and if a parent block is reported, suppress warnings on its children.
    for (final candidate in candidates) {
      if (suppressed.contains(candidate.node)) continue;

      final hash = hasher.computeHash(candidate.node);
      final group = groups[hash];
      if (group == null) continue;

      // Filter group to only include non-suppressed candidates
      final activeGroup = group
          .where((c) => !suppressed.contains(c.node))
          .toList();
      if (activeGroup.length < 2) continue;

      final firstOccurrence = activeGroup.first;
      final firstOffset = firstOccurrence.node.offset;
      final firstLine = lineInfo.getLocation(firstOffset).lineNumber;

      for (var i = 1; i < activeGroup.length; i++) {
        final duplicate = activeGroup[i];

        // Report on the enclosing declaration if it's a function body,
        // otherwise report directly on the statement block itself.
        final isFuncBody = duplicate.node.parent is FunctionBody;
        final reportNode = isFuncBody
            ? (duplicate.enclosingDeclaration ?? duplicate.node)
            : duplicate.node;

        _rule.reportAtNode(
          reportNode,
          arguments: [firstLine],
        );

        // Mark this duplicate block and all its descendants as suppressed
        suppressed.add(duplicate.node);
        _suppressDescendants(duplicate.node, suppressed);
      }
    }
  }

  void _suppressDescendants(AstNode root, Set<AstNode> suppressed) {
    root.accept(_DescendantCollector(suppressed, root));
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

    _checkAndCollect(node, node.statements.length);
    super.visitBlock(node);
  }

  @override
  void visitExpressionFunctionBody(ExpressionFunctionBody node) {
    _checkAndCollect(node, 1);
    super.visitExpressionFunctionBody(node);
  }

  void _checkAndCollect(AstNode node, int statementCount) {
    if (statementCount < parameters.minStatements) return;

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
