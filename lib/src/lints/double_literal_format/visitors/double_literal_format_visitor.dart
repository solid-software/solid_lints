import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:solid_lints/src/lints/double_literal_format/double_literal_format_rule.dart'
    show DoubleLiteralFormatRule;
import 'package:solid_lints/src/lints/double_literal_format/double_literal_format_utils.dart';

/// A visitor that checks that double literals are formatted according to
/// [DoubleLiteralFormatRule].
/// {@macro solid_lints.double_literal_format.example}
class DoubleLiteralFormatVisitor extends SimpleAstVisitor<void> {
  final DoubleLiteralFormatRule _rule;

  /// Creates a new instance of [DoubleLiteralFormatVisitor].
  DoubleLiteralFormatVisitor(this._rule);

  @override
  void visitDoubleLiteral(DoubleLiteral node) {
    super.visitDoubleLiteral(node);

    final lexeme = node.literal.lexeme;

    if (lexeme.hasLeadingZero) {
      _rule.reportAtNode(
        node,
        diagnosticCode: DoubleLiteralFormatRule.leadingZeroCode,
      );
      return;
    }

    if (lexeme.hasLeadingDecimalPoint) {
      _rule.reportAtNode(
        node,
        diagnosticCode: DoubleLiteralFormatRule.leadingDecimalCode,
      );
      return;
    }

    if (lexeme.hasTrailingZero) {
      _rule.reportAtNode(
        node,
        diagnosticCode: DoubleLiteralFormatRule.trailingZeroCode,
      );
      return;
    }
  }
}
