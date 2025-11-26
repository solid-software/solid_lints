import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

/// Parses the provided type string to extract a [NamedType].
NamedType parseNamedTypeFromString(String typeString) {
  try {
    final namedTypeFinder = _NamedTypeFinder();

    final parseResult = parseString(content: "$typeString _;");
    parseResult.unit.visitChildren(namedTypeFinder);

    return namedTypeFinder.foundNamedType!;
  } catch (_) {
    throw Exception("No NamedType could be parsed from the input "
        "typeString: '$typeString'. Ensure it's a valid Dart "
        "type declaration.");
  }
}

class _NamedTypeFinder extends GeneralizingAstVisitor<void> {
  NamedType? _foundNamedType;

  NamedType? get foundNamedType => _foundNamedType;

  @override
  void visitNamedType(NamedType namedType) {
    _foundNamedType ??= namedType;
  }
}

///
extension ChildNamedTypes on NamedType {
  /// Retrieves child [NamedType] instances from type arguments.
  List<NamedType> get childNamedTypes =>
      typeArguments?.arguments.whereType<NamedType>().toList() ?? [];

  /// Gets the token name of this type instance.
  String get tokenName => name.toString();

  /// Checks if the current token name is 'dynamic'.
  bool get isDynamic => tokenName == "dynamic";

  /// Checks if the current token name is 'Object'.
  bool get isObject => tokenName == "Object";

  /// Checks if this node is a subtype of the specified node
  /// based on their structures.
  bool isSubtypeOf({required NamedType node}) {
    if (isDynamic || isObject) return true;

    if (tokenName != node.tokenName) return false;

    if (childNamedTypes.isEmpty) return true;

    if (childNamedTypes.length != node.childNamedTypes.length) return false;

    for (int i = 0; i < childNamedTypes.length; i++) {
      if (!childNamedTypes[i].isSubtypeOf(node: node.childNamedTypes[i])) {
        return false;
      }
    }

    return true;
  }
}
