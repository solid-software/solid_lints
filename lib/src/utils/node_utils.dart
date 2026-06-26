import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/element/element.dart';

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
