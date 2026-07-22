import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:solid_lints/src/lints/avoid_similar_names/utils/name_tokenizer.dart';

/// Represents a variable or parameter collected from a scope.
class ScopeVariable {
  /// The resolved type of the variable, if available.
  final DartType? type;

  /// The AST node representing this variable declaration.
  final AstNode node;

  /// The token representing the name.
  final Token nameToken;

  /// The individual word/digit tokens of the name.
  final List<String> tokens;

  /// The minimum length for a variable name to be considered descriptive enough
  /// to be analyzed for similarity.
  static const minDescriptiveNameLength = 3;

  /// Creates a new [ScopeVariable] if the [nameToken] is descriptive enough
  /// to be analyzed for similarity. Returns `null` if the cleaned name
  /// is too short.
  static ScopeVariable? createOrNull({
    required Token nameToken,
    required DartType? type,
    required AstNode node,
  }) {
    final cleaned = NameTokenizer.cleanName(nameToken.lexeme);
    if (cleaned.length < minDescriptiveNameLength) return null;

    return ScopeVariable._(
      nameToken: nameToken,
      type: type,
      node: node,
      tokens: NameTokenizer.tokenize(cleaned),
    );
  }

  ScopeVariable._({
    required this.nameToken,
    required this.type,
    required this.node,
    required this.tokens,
  });
}
