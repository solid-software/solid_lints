import 'package:analyzer/dart/ast/ast.dart' show Identifier, MethodDeclaration;
import 'package:solid_lints/lints/member_ordering/models/annotation.dart';
import 'package:solid_lints/lints/member_ordering/models/member_group.dart';
import 'package:solid_lints/lints/member_ordering/models/member_type.dart';
import 'package:solid_lints/lints/member_ordering/member_ordering_utils.dart';
import 'package:solid_lints/lints/member_ordering/models/modifier.dart';

/// Data class represents class method
class MethodMemberGroup extends MemberGroup {
  /// Shows if method is static member of a class
  final bool isStatic;

  /// Shows if method return type is nullable
  final bool isNullable;

  /// Represents method name
  final String? name;

  /// Creates instance of [MethodMemberGroup]
  const MethodMemberGroup({
    required this.isNullable,
    required this.isStatic,
    required this.name,
    required super.annotation,
    required super.memberType,
    required super.modifier,
    required super.rawRepresentation,
  });

  /// Named constructor to create an instance of [MethodMemberGroup] with name
  factory MethodMemberGroup.named({
    required String name,
    required MemberType memberType,
    required String rawRepresentation,
  }) =>
      MethodMemberGroup(
        name: name,
        isNullable: false,
        isStatic: false,
        modifier: Modifier.unset,
        annotation: Annotation.unset,
        memberType: memberType,
        rawRepresentation: rawRepresentation,
      );

  /// Parses [MethodDeclaration] and returns instance of [MethodMemberGroup]
  factory MethodMemberGroup.parse(MethodDeclaration declaration) {
    final methodName = declaration.name.lexeme;
    final annotation = parseAnnotation(declaration);
    final modifier = Identifier.isPrivateName(methodName)
        ? Modifier.private
        : Modifier.public;

    return MethodMemberGroup(
      name: methodName.toLowerCase(),
      annotation: annotation ?? Annotation.unset,
      isStatic: declaration.isStatic,
      isNullable: declaration.returnType?.question != null,
      memberType: MemberType.method,
      modifier: modifier,
      rawRepresentation: '',
    );
  }

  @override
  int getSortingCoefficient() {
    var coefficient = 0;

    coefficient += isStatic ? 1 : 0;
    coefficient += isNullable ? 1 : 0;
    coefficient += annotation != Annotation.unset ? 1 : 0;
    coefficient += modifier != Modifier.unset ? 1 : 0;
    coefficient += name != null ? 10 : 0;

    return coefficient;
  }

  @override
  String toString() => rawRepresentation;
}
