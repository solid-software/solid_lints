import 'package:solid_lints/src/lints/member_ordering/models/annotation.dart';
import 'package:solid_lints/src/lints/member_ordering/models/field_keyword.dart';
import 'package:solid_lints/src/lints/member_ordering/models/member_group/constructor_member_group.dart';
import 'package:solid_lints/src/lints/member_ordering/models/member_group/field_member_group.dart';
import 'package:solid_lints/src/lints/member_ordering/models/member_group/get_set_member_group.dart';
import 'package:solid_lints/src/lints/member_ordering/models/member_group/member_group.dart';
import 'package:solid_lints/src/lints/member_ordering/models/member_group/method_member_group.dart';
import 'package:solid_lints/src/lints/member_ordering/models/member_type.dart';
import 'package:solid_lints/src/lints/member_ordering/models/modifier.dart';

/// Extension methods for [MemberGroup] to check if a parsed group matches
/// the properties of this group.
extension MemberGroupExtensions on MemberGroup {
  /// Checks whether this [MemberGroup] satisfies the properties
  /// of the [parsedGroup].
  bool satisfies(MemberGroup parsedGroup) {
    if (!_matchesBaseProperties(parsedGroup)) {
      return false;
    }

    final group = this;
    return switch ((group, parsedGroup)) {
      (final ConstructorMemberGroup g, final ConstructorMemberGroup p) =>
        _isConstructor(g, p),
      (final MethodMemberGroup g, final MethodMemberGroup p) => _isMethod(g, p),
      (final GetSetMemberGroup g, final GetSetMemberGroup p) => _isGetSet(g, p),
      (final FieldMemberGroup g, final FieldMemberGroup p) => _isField(g, p),
      _ => false,
    };
  }

  bool _matchesBaseProperties(MemberGroup parsedGroup) =>
      (modifier == Modifier.unset || modifier == parsedGroup.modifier) &&
      (annotation == Annotation.unset || annotation == parsedGroup.annotation);

  bool _isConstructor(
    ConstructorMemberGroup g,
    ConstructorMemberGroup p,
  ) =>
      (!g.isFactory || g.isFactory == p.isFactory) &&
      (!g.isNamed || g.isNamed == p.isNamed);

  bool _isMethod(MethodMemberGroup g, MethodMemberGroup p) =>
      (!g.isStatic || g.isStatic == p.isStatic) &&
      (!g.isNullable || g.isNullable == p.isNullable) &&
      (g.name == null || g.name == p.name);

  bool _isGetSet(GetSetMemberGroup g, GetSetMemberGroup p) =>
      (g.memberType == p.memberType ||
          (g.memberType == MemberType.getterAndSetter &&
              (p.memberType == MemberType.getter ||
                  p.memberType == MemberType.setter))) &&
      (!g.isStatic || g.isStatic == p.isStatic) &&
      (!g.isNullable || g.isNullable == p.isNullable);

  bool _isField(FieldMemberGroup g, FieldMemberGroup p) =>
      (!g.isLate || g.isLate == p.isLate) &&
      (!g.isStatic || g.isStatic == p.isStatic) &&
      (!g.isNullable || g.isNullable == p.isNullable) &&
      (g.keyword == FieldKeyword.unset || g.keyword == p.keyword);
}
