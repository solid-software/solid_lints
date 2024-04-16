import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';

/// Check node is override method from its metadata
bool isOverride(List<Annotation> metadata) => metadata.any(
      (node) =>
          node.name.name == 'override' && node.atSign.type == TokenType.AT,
    );

/// Returns human readable node type
/// Self explanatory
String humanReadableNodeType(AstNode? node) {
  if (node is ClassDeclaration) {
    return 'Class';
  } else if (node is EnumDeclaration) {
    return 'Enum';
  } else if (node is ExtensionDeclaration) {
    return 'Extension';
  } else if (node is MixinDeclaration) {
    return 'Mixin';
  }

  return 'Node';
}

/// Analyzes and navigates AST nodes specific to type analysis.
class TypeAnalyzerNode extends GeneralizingAstVisitor<void> {
  NamedType? _currentTypeNode;

  /// List of child analyzer nodes.
  final List<TypeAnalyzerNode> childNodes = [];

  /// The root node of the analyzer tree.
  final TypeAnalyzerNode? rootNode;

  /// Returns the name of the current node type.
  String? get typeName => _currentTypeNode?.childEntities.first.toString();

  /// Checks if the current type name is 'dynamic'.
  bool get isDynamicType => typeName == "dynamic";

  /// Checks if the current type name is 'Object'.
  bool get isObjectType => typeName == "Object";

  /// Checks if this node is the root node of the analyzer tree.
  bool get isRootNode => rootNode == null;

  /// Constructor to create a node with an optional root node.
  TypeAnalyzerNode({this.rootNode});

  /// Factory constructor to create a [TypeAnalyzerNode] from a [String].
  factory TypeAnalyzerNode.fromTypeString(String typeString) {
    final parseResult = parseString(content: "$typeString a;");
    final analyzerNode = TypeAnalyzerNode();
    parseResult.unit.visitChildren(analyzerNode);
    return analyzerNode;
  }

  /// Factory constructor to create a [TypeAnalyzerNode] from an [AstNode].
  factory TypeAnalyzerNode.fromAstNode(AstNode node) {
    final analyzerNode = TypeAnalyzerNode();
    node.visitChildren(analyzerNode);
    return analyzerNode;
  }

  /// Determines if the current node includes another analyzer node.
  bool isInclude({required TypeAnalyzerNode node}) {
    if (isDynamicType || isObjectType) return true;

    if (this != node) return false;

    if (isRootNode && childNodes.isEmpty) return true;

    if (childNodes.length != node.childNodes.length) return false;

    for (int i = 0; i < childNodes.length; i++) {
      if (!childNodes[i].isInclude(node: node.childNodes[i])) {
        return false;
      }
    }

    return true;
  }

  /// Visit a named type and process it into the tree structure.
  @override
  void visitNamedType(NamedType node) {
    if (_currentTypeNode == null) {
      _currentTypeNode = node;
      node.typeArguments?.arguments.forEach((arg) {
        if (arg is NamedType) {
          final newVisitor = TypeAnalyzerNode(rootNode: this);
          arg.accept(newVisitor);
          childNodes.add(newVisitor);
        }
      });
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TypeAnalyzerNode &&
          runtimeType == other.runtimeType &&
          typeName == other.typeName;

  @override
  int get hashCode => typeName.hashCode;
}
