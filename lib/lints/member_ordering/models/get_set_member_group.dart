import 'package:analyzer/dart/ast/ast.dart' show MethodDeclaration;
import 'package:solid_lints/lints/member_ordering/models/annotation.dart';
import 'package:solid_lints/lints/member_ordering/models/member_group.dart';
import 'package:solid_lints/lints/member_ordering/models/member_type.dart';
import 'package:solid_lints/lints/member_ordering/member_ordering_utils.dart';
import 'package:solid_lints/lints/member_ordering/models/modifier.dart';

/// Data class represents class getter or setter
class GetSetMemberGroup extends MemberGroup {
  /// Shows if getter/setter is static class member
  final bool isStatic;

  /// Show if return type of getter/setter is nullable type
  final bool isNullable;

  /// Creates instance of [GetSetMemberGroup]
  const GetSetMemberGroup({
    required this.isNullable,
    required this.isStatic,
    required super.annotation,
    required super.memberType,
    required super.modifier,
    required super.rawRepresentation,
  });

  /// Parses [MethodDeclaration] and returns instance of [GetSetMemberGroup]
  factory GetSetMemberGroup.parse(MethodDeclaration declaration) {
    final annotation = parseAnnotation(declaration);
    final type = declaration.isGetter ? MemberType.getter : MemberType.setter;
    final modifier = parseModifier(declaration.name.lexeme);

    return GetSetMemberGroup(
      annotation: annotation ?? Annotation.unset,
      isStatic: declaration.isStatic,
      isNullable: declaration.returnType?.question != null,
      memberType: type,
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

    return coefficient;
  }

  @override
  String toString() => rawRepresentation;
}
