import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:collection/collection.dart';
import 'package:solid_lints/src/lints/no_magic_number/models/no_magic_number_parameters.dart';
import 'package:solid_lints/src/models/solid_lint_rule.dart';
import 'package:solid_lints/src/utils/node_utils.dart';

/// The AST visitor that checks if double and integer literals are magic
/// numbers.
class NoMagicNumberRuleVisitor extends SimpleAstVisitor<void> {
  final SolidLintRule _rule;
  final NoMagicNumberParameters _parameters;

  /// Creates a new instance of [NoMagicNumberRuleVisitor].
  NoMagicNumberRuleVisitor(this._rule, this._parameters);

  @override
  void visitDoubleLiteral(DoubleLiteral node) {
    _checkLiteral(node);
  }

  @override
  void visitIntegerLiteral(IntegerLiteral node) {
    _checkLiteral(node);
  }

  void _checkLiteral(Literal node) {
    if (_isNotMagicNumber(node)) return;
    if (_isInsideVariable(node)) return;
    if (_isInsideCollectionLiteral(node)) return;
    if (_isWidgetParameter(node)) return;

    if (node.isInsideConstConstructor) return;
    if (node.isInDateTime) return;
    if (node.isInsideIndexExpression) return;
    if (node.isInsideEnumConstantArguments) return;
    if (node.isDefaultValue) return;
    if (node.isInConstructorInitializer) return;

    _rule.reportAtNode(node);
  }

  bool _isNotMagicNumber(Literal l) =>
      (l is DoubleLiteral && _parameters.allowedNumbers.contains(l.value)) ||
      (l is IntegerLiteral && _parameters.allowedNumbers.contains(l.value));

  /// Returns the effective parent of [l], skipping over a unary
  /// [PrefixExpression] (e.g. the `-` in `-42`).
  AstNode? _effectiveParent(Literal l) =>
      l.parent is PrefixExpression ? l.parent?.parent : l.parent;

  /// Returns `true` if the literal is the direct initializer of a variable
  /// declaration.
  ///
  /// Allows `var x = 42` (literal gets a name) but reports `var r = x + 42`
  /// (42 is a magic number inside an expression).
  bool _isInsideVariable(Literal l) =>
      _effectiveParent(l) is VariableDeclaration;

  /// Returns `true` if the literal is inside a collection literal.
  ///
  /// Covers list elements (`[42]`, `[-42]`), set elements (`{42}`, `{-42}`),
  /// and map keys/values (`{42: 'a'}`, `{-42: 'a'}`, `{'a': -42}`).
  ///
  /// Unary prefix expressions (e.g. `-42`) are skipped transparently so that
  /// the effective parent—the collection literal—is checked instead of the
  /// intermediate [PrefixExpression] node.
  bool _isInsideCollectionLiteral(Literal l) {
    final p = _effectiveParent(l);
    return p is TypedLiteral ||
        p is MapLiteralEntry ||
        p is RecordLiteral ||
        p is RecordLiteralNamedField;
  }

  bool _isWidgetParameter(Literal literal) {
    if (!_parameters.allowedInWidgetParams) return false;

    final widgetCreationExpression = literal.thisOrAncestorMatching(
      _isWidgetCreationExpression,
    );

    return widgetCreationExpression != null;
  }

  bool _isWidgetCreationExpression(AstNode node) {
    if (node is! InstanceCreationExpression) return false;

    final staticType = node.staticType;
    if (staticType is! InterfaceType) return false;

    final widgetSupertype = staticType.allSupertypes.firstWhereOrNull(
      (supertype) => supertype.getDisplayString() == 'Widget',
    );

    return widgetSupertype != null;
  }
}
