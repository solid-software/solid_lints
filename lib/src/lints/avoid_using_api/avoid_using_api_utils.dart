import 'package:analyzer/dart/ast/ast.dart';

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
