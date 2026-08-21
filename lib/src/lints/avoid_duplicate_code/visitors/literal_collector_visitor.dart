import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/models/literal_info.dart';

/// A visitor that traverses an AST node and collects literal values and their
/// source spans in deterministic traversal order.
class LiteralCollectorVisitor extends RecursiveAstVisitor<void> {
  final List<LiteralInfo> _literals = [];

  /// Collects all literals from the given [node].
  static List<LiteralInfo> collect(AstNode node) {
    final visitor = LiteralCollectorVisitor();
    node.accept(visitor);
    return visitor._literals;
  }

  void _addLiteral(AstNode node, String text) {
    _literals.add(
      LiteralInfo(
        text: text,
        offset: node.offset,
        length: node.length,
      ),
    );
  }

  @override
  void visitPrefixExpression(PrefixExpression node) {
    if (node case PrefixExpression(
      operator: Token(type: TokenType.MINUS || TokenType.PLUS),
      operand: IntegerLiteral() || DoubleLiteral(),
    )) {
      _addLiteral(node, node.toSource());
      return;
    }
    super.visitPrefixExpression(node);
  }

  @override
  void visitIntegerLiteral(IntegerLiteral node) {
    _addLiteral(node, node.literal.lexeme);
    super.visitIntegerLiteral(node);
  }

  @override
  void visitDoubleLiteral(DoubleLiteral node) {
    _addLiteral(node, node.literal.lexeme);
    super.visitDoubleLiteral(node);
  }

  @override
  void visitSimpleStringLiteral(SimpleStringLiteral node) {
    _addLiteral(node, node.toSource());
    super.visitSimpleStringLiteral(node);
  }

  @override
  void visitInterpolationString(InterpolationString node) {
    _addLiteral(node, "'${node.value}'");
    super.visitInterpolationString(node);
  }

  @override
  void visitBooleanLiteral(BooleanLiteral node) {
    _addLiteral(node, node.value ? 'true' : 'false');
    super.visitBooleanLiteral(node);
  }

  @override
  void visitSymbolLiteral(SymbolLiteral node) {
    _addLiteral(node, node.toSource());
    super.visitSymbolLiteral(node);
  }
}
