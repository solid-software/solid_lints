import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/models/avoid_duplicate_code_parameters.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/models/body_candidate.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/utils/token_utils.dart';

/// A visitor that collects all block-level duplicate code candidates.
class CandidateVisitor extends RecursiveAstVisitor<void> {
  /// The list of collected candidates.
  final List<BodyCandidate> candidates = [];

  /// The parameters for the lint rule.
  final AvoidDuplicateCodeParameters parameters;

  /// Creates a new instance of [CandidateVisitor].
  CandidateVisitor(this.parameters);

  @override
  void visitBlock(Block node) {
    // If checkBlocks is false, only consider blocks that represent function
    // bodies.
    if (!parameters.checkBlocks && node.parent is! BlockFunctionBody) {
      super.visitBlock(node);
      return;
    }

    _checkAndCollect(node, node.tokenCount);
    super.visitBlock(node);
  }

  @override
  void visitExpressionFunctionBody(ExpressionFunctionBody node) {
    _checkAndCollect(node, node.tokenCount);
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
