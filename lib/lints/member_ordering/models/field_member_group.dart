import 'package:analyzer/dart/ast/ast.dart' show FieldDeclaration;
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:solid_lints/lints/member_ordering/models/annotation.dart';
import 'package:solid_lints/lints/member_ordering/models/field_keyword.dart';
import 'package:solid_lints/lints/member_ordering/models/member_group.dart';
import 'package:solid_lints/lints/member_ordering/models/member_type.dart';
import 'package:solid_lints/lints/member_ordering/member_ordering_utils.dart';
import 'package:solid_lints/lints/member_ordering/models/modifier.dart';

/// Data class represents class field
class FieldMemberGroup extends MemberGroup {
  /// Shows if field is static member of class
  final bool isStatic;

  /// Shows if field is nullable type
  final bool isNullable;

  /// Show if field is late initialization
  final bool isLate;

  /// Represents field keyword
  final FieldKeyword keyword;

  /// Creates instance of [FieldMemberGroup]
  const FieldMemberGroup({
    required this.isLate,
    required this.isNullable,
    required this.isStatic,
    required this.keyword,
    required super.annotation,
    required super.memberType,
    required super.modifier,
    required super.rawRepresentation,
  });

  /// Parses [FieldDeclaration] and creates instance of [FieldMemberGroup]
  factory FieldMemberGroup.parse(FieldDeclaration declaration) {
    final annotation = parseAnnotation(declaration);
    final modifier = parseModifier(
      declaration.fields.variables.first.name.lexeme,
    );
    final isNullable = declaration.fields.type?.type?.nullabilitySuffix ==
        NullabilitySuffix.question;
    final keyword = _FieldMemberGroupUtils.parseKeyWord(declaration);

    return FieldMemberGroup(
      annotation: annotation ?? Annotation.unset,
      isStatic: declaration.isStatic,
      isNullable: isNullable,
      isLate: declaration.fields.isLate,
      memberType: MemberType.field,
      modifier: modifier,
      keyword: keyword,
      rawRepresentation: '',
    );
  }

  @override
  int getSortingCoefficient() {
    var coefficient = 0;

    coefficient += isStatic ? 1 : 0;
    coefficient += isNullable ? 1 : 0;
    coefficient += isLate ? 1 : 0;
    coefficient += keyword != FieldKeyword.unset ? 1 : 0;
    coefficient += annotation != Annotation.unset ? 1 : 0;
    coefficient += modifier != Modifier.unset ? 1 : 0;

    return coefficient;
  }

  @override
  String toString() => rawRepresentation;
}

class _FieldMemberGroupUtils {
  static FieldKeyword parseKeyWord(FieldDeclaration declaration) {
    return declaration.fields.isConst
        ? FieldKeyword.isConst
        : declaration.fields.isFinal
            ? FieldKeyword.isFinal
            : FieldKeyword.unset;
  }
}
