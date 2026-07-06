import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:solid_lints/src/utils/path_utils.dart';

/// Check node is override method from its metadata
bool isOverride(List<Annotation> metadata) => metadata.any(
  (node) => node.name.name == 'override' && node.atSign.type == TokenType.AT,
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

/// Extension on [SimpleIdentifier] to provide scope and property utility
/// checks.
extension SimpleIdentifierExtension on SimpleIdentifier {
  /// Returns `true` if this identifier is a property accessed on another
  /// object (e.g. `state.context`), but not on `this` (e.g. `this.context`).
  bool get isPropertyOfOtherObject {
    final parent = this.parent;
    if (parent is PrefixedIdentifier && this == parent.identifier) {
      return true;
    }
    if (parent is PropertyAccess && this == parent.propertyName) {
      var target = parent.target;
      while (target is ParenthesizedExpression) {
        target = target.expression;
      }
      return target is! ThisExpression && target is! SuperExpression;
    }
    return false;
  }

  /// Returns `true` if this identifier refers to a variable declared inside
  /// the body of the function that owns [as] (i.e. a local variable in the
  /// same scope).
  bool isDeclaredInSameFunction({required SimpleFormalParameter as}) {
    final element = this.element;
    if (element is! LocalVariableElement) return false;

    final nearestFunction = as.parent?.parent;
    if (nearestFunction is! FunctionExpression) return false;

    final body = nearestFunction.body;
    final declOffset = element.firstFragment.nameOffset;
    if (declOffset == null) return false;
    return declOffset >= body.offset && declOffset < body.end;
  }

  /// Returns the library URI string of the element, or null.
  String? get sourceUrl => element?.libraryUri;
}

/// Extension on [AstNode] to provide generic context/traversal checks.
extension AstNodeExtension on AstNode {
  /// Returns `true` if the node is within the default value of a formal
  /// parameter.
  bool get isDefaultValue =>
      thisOrAncestorOfType<DefaultFormalParameter>() != null;

  /// Returns `true` if the node is within a constructor initializer.
  bool get isInConstructorInitializer =>
      thisOrAncestorOfType<ConstructorInitializer>() != null;

  /// Returns `true` if the node is within a const constructor invocation or
  /// annotation.
  bool get isInsideConstConstructor =>
      thisOrAncestorMatching((ancestor) {
        return (ancestor is InstanceCreationExpression && ancestor.isConst) ||
            ancestor is Annotation;
      }) !=
      null;

  /// Returns `true` if the node is within enum constant arguments.
  bool get isInsideEnumConstantArguments =>
      thisOrAncestorMatching(
        (ancestor) => ancestor is EnumConstantArguments,
      ) !=
      null;

  /// Returns `true` if the node is within a DateTime constructor invocation.
  bool get isInDateTime =>
      thisOrAncestorMatching(
        (a) =>
            a is InstanceCreationExpression &&
            a.staticType?.getDisplayString() == 'DateTime',
      ) !=
      null;

  /// Returns `true` if the node is the child (optionally wrapped in a prefix
  /// expression) of an index expression (e.g. `list[42]` or `list[-42]`).
  bool get isInsideIndexExpression {
    final p = parent is PrefixExpression ? parent?.parent : parent;
    return p is IndexExpression;
  }
}

/// Extension on [NamedType] to provide source URL utility.
extension NamedTypeExtension on NamedType {
  /// Returns the library URI string of the element, or null.
  String? get sourceUrl => element?.libraryUri;
}

/// Extension on [ArgumentList] to check for parameter names.
extension ArgumentListExtension on ArgumentList {
  /// Returns `true` if this argument list contains a named parameter argument
  /// with the given [name].
  bool containsNamed(String name) => arguments.any(
    (arg) => arg is NamedExpression && arg.name.label.name == name,
  );
}

/// Extension on [Element] to provide element utility checks.
extension ElementExtension on Element {
  /// Returns the library URI string of this element, or null.
  String? get libraryUri => library?.uri.toString();

  /// Returns `true` if this element or its enclosing element matches the
  /// given [className] and [source].
  bool isMemberOrClass({
    required String className,
    required String source,
  }) {
    final target = this is InterfaceElement ? this : enclosingElement;

    if (target case InterfaceElement() || ExtensionElement()
        when target != null) {
      return target.name == className &&
          matchesSource(target.libraryUri, source);
    }

    return false;
  }
}

/// Extension on [VariableDeclaration] to check declared type.
extension VariableDeclarationExtension on VariableDeclaration {
  /// Returns the type of the declared variable, or null.
  DartType? get declaredType {
    final element = declaredFragment?.element;
    return element is VariableElement ? element.type : null;
  }
}
