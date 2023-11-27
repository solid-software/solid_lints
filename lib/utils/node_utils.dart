import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';

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

/// Extension to get library of the node
extension SimpleIdentifierParentSourceExtension on SimpleIdentifier {
  /// Returns library of the node
  String? get sourceUrl {
    final parentSource = staticElement?.librarySource;
    final parentSourceName = parentSource?.uri.toString();
    return parentSourceName;
  }
}

/// Extension to get library of the node
extension NamedTypeParentSourceExtension on NamedType {
  /// Returns library of the node
  String? get sourceUrl {
    final parentSource = element?.librarySource;
    final parentSourceName = parentSource?.uri.toString();
    return parentSourceName;
  }
}
