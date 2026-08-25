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
  bool isDeclaredInSameFunction({required FormalParameter as}) {
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

  /// Returns the target expression if this identifier is part of a member
  /// access (e.g., `target.member`, `target.method()`, `target.field`),
  /// otherwise null.
  Expression? get memberAccessTarget => switch (parent) {
    PropertyAccess(:final propertyName, :final realTarget)
        when propertyName == this =>
      realTarget,
    MethodInvocation(:final methodName, :final realTarget)
        when methodName == this =>
      realTarget,
    PrefixedIdentifier(:final identifier, :final prefix)
        when identifier == this =>
      prefix,
    _ => null,
  };
}

/// Extension on [AstNode] to provide generic context/traversal checks.
extension AstNodeExtension on AstNode {
  /// Returns an iterable of all parent nodes of this node up to the root.
  Iterable<AstNode> get ancestors sync* {
    for (var current = parent; current != null; current = current.parent) {
      yield current;
    }
  }

  /// Returns `true` if the node is within the default value of a formal
  /// parameter.
  bool get isDefaultValue =>
      thisOrAncestorMatching(
        (ancestor) =>
            ancestor is FormalParameter && ancestor.defaultClause != null,
      ) !=
      null;

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

  /// Traverses up the AST from a pattern node to find the root expression
  /// being matched.
  Expression? get matchedPatternExpression {
    AstNode? current = this;
    while (current != null) {
      switch (current) {
        case PatternField() ||
            ListPattern() ||
            MapPattern() ||
            RecordPattern() ||
            ForEachPartsWithPattern():
          return null;
        case PatternVariableDeclaration(:final expression) ||
            PatternAssignment(:final expression) ||
            SwitchStatement(:final expression) ||
            SwitchExpression(:final expression) ||
            IfStatement(:final expression) ||
            IfElement(:final expression):
          return expression;
        default:
          current = current.parent;
      }
    }
    return null;
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
    (arg) => arg is NamedArgument && arg.name.lexeme == name,
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

  /// Checks whether this element is a non-static instance member.
  bool get isInstanceMember => switch (this) {
    PropertyAccessorElement(:final isStatic) ||
    MethodElement(:final isStatic) ||
    FieldElement(:final isStatic) => !isStatic,
    _ => false,
  };

  /// Checks whether this element is a non-static instance method.
  bool get isInstanceMethod => this is MethodElement && isInstanceMember;

  /// Checks whether this element belongs to the analyzed project.
  bool get isFromProject {
    final session = this.session;
    if (session == null) return false;

    final sourcePath = library?.firstFragment.source.fullName;
    if (sourcePath == null) return false;

    return session.analysisContext.contextRoot.isAnalyzed(sourcePath);
  }

  /// Returns the enclosing [InterfaceElement] of this element (recursively),
  /// or null if none.
  InterfaceElement? get enclosingInterface =>
      enclosingElements.whereType<InterfaceElement>().firstOrNull;

  /// Returns an iterable of this element and all its enclosing elements.
  Iterable<Element> get enclosingElements sync* {
    for (Element? e = this; e != null; e = e.enclosingElement) {
      yield e;
    }
  }

  /// Resolves type parameters to their bounds recursively to prevent cycle
  /// loops.
  Element? get resolveTypeParameter {
    Element? current = this;
    final visited = <Element>{};
    while (current is TypeParameterElement) {
      if (!visited.add(current)) break;
      current = current.bound?.element;
    }
    return current;
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

/// Extension on [BinaryExpression] to check binary expressions.
extension BinaryExpressionExtension on BinaryExpression {
  /// Returns `true` if this is an equality expression (== or !=).
  bool get isEquality =>
      operator.type == TokenType.EQ_EQ || operator.type == TokenType.BANG_EQ;

  /// Returns `true` if one of the operands is a null literal.
  bool get hasNullOperand =>
      leftOperand is NullLiteral || rightOperand is NullLiteral;

  /// Returns `true` if this expression is a null check.
  bool get isNullCheck => isEquality && hasNullOperand;
}

/// Extension on [Expression] to provide target unwrapping and resolving
/// utilities.
extension ExpressionExtension on Expression {
  /// Returns the target of a property access, prefixed identifier, or index
  /// expression, or null for other expressions.
  Expression? get targetExpression => switch (this) {
    PropertyAccess(:final realTarget) => realTarget,
    PrefixedIdentifier(:final prefix) => prefix,
    IndexExpression(:final realTarget) => realTarget,
    _ => null,
  };

  /// Returns the member element referenced or operated on by this expression,
  /// or null if none.
  Element? get memberElement => switch (this) {
    SimpleIdentifier(:final element) => element,
    MethodInvocation(:final methodName) => methodName.element,
    PropertyAccess(:final propertyName) => propertyName.element,
    AssignmentExpression(:final writeElement, :final readElement) ||
    PostfixExpression(:final writeElement, :final readElement) ||
    PrefixExpression(
      :final writeElement,
      :final readElement,
    ) => writeElement ?? readElement,
    IndexExpression(:final element) => element,
    BinaryExpression(:final element) => element,
    _ => null,
  };
}

/// Extension on nullable [Expression] to provide helper checks.
extension ExpressionNullableExtension on Expression? {
  /// Unwraps casts ([AsExpression]) and null assertions (e.g. `expr!`)
  /// recursively down to the core expression.
  Expression? get unwrapTarget {
    var current = this?.unParenthesized;
    while (true) {
      if (current case AsExpression(:final expression)) {
        current = expression.unParenthesized;
      } else if (current
          case PostfixExpression(
            :final operand,
            :final operator,
          )
          when operator.type == TokenType.BANG) {
        current = operand.unParenthesized;
      } else {
        return current;
      }
    }
  }

  /// Returns `true` if this expression is `this` or `super` or null.
  bool get isThisOrSuperOrNull =>
      this == null || this is ThisExpression || this is SuperExpression;

  /// Returns `true` if this expression is `this` or `super`.
  bool get isThisOrSuper => this is ThisExpression || this is SuperExpression;
}

/// Extension on [MethodDeclaration] to provide AST helper getters.
extension MethodDeclarationExtension on MethodDeclaration {
  /// Returns the single return expression of a method, or null if the
  /// method body has multiple statements or no return expression.
  Expression? get singleReturnExpression => switch (body) {
    ExpressionFunctionBody(:final expression) => expression,
    BlockFunctionBody(
      block: Block(statements: [ReturnStatement(:final expression?)]),
    ) =>
      expression,
    _ => null,
  };
}
