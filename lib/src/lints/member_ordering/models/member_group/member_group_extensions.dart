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
  bool satisfies(MemberGroup parsedGroup) =>
      _isConstructorGroup(parsedGroup) ||
      _isFieldGroup(parsedGroup) ||
      _isGetSetGroup(parsedGroup) ||
      _isMethodGroup(parsedGroup);

  bool _isConstructorGroup(MemberGroup parsedGroup) {
    final group = this;
    return group is ConstructorMemberGroup &&
        parsedGroup is ConstructorMemberGroup &&
        (!group.isFactory || group.isFactory == parsedGroup.isFactory) &&
        (!group.isNamed || group.isNamed == parsedGroup.isNamed) &&
        (group.modifier == Modifier.unset ||
            group.modifier == parsedGroup.modifier) &&
        (group.annotation == Annotation.unset ||
            group.annotation == parsedGroup.annotation);
  }

  bool _isMethodGroup(MemberGroup parsedGroup) {
    final group = this;
    return group is MethodMemberGroup &&
        parsedGroup is MethodMemberGroup &&
        (!group.isStatic || group.isStatic == parsedGroup.isStatic) &&
        (!group.isNullable || group.isNullable == parsedGroup.isNullable) &&
        (group.name == null || group.name == parsedGroup.name) &&
        (group.modifier == Modifier.unset ||
            group.modifier == parsedGroup.modifier) &&
        (group.annotation == Annotation.unset ||
            group.annotation == parsedGroup.annotation);
  }

  bool _isGetSetGroup(MemberGroup parsedGroup) {
    final group = this;
    return group is GetSetMemberGroup &&
        parsedGroup is GetSetMemberGroup &&
        (group.memberType == parsedGroup.memberType ||
            (group.memberType == MemberType.getterAndSetter &&
                (parsedGroup.memberType == MemberType.getter ||
                    parsedGroup.memberType == MemberType.setter))) &&
        (!group.isStatic || group.isStatic == parsedGroup.isStatic) &&
        (!group.isNullable || group.isNullable == parsedGroup.isNullable) &&
        (group.modifier == Modifier.unset ||
            group.modifier == parsedGroup.modifier) &&
        (group.annotation == Annotation.unset ||
            group.annotation == parsedGroup.annotation);
  }

  bool _isFieldGroup(MemberGroup parsedGroup) {
    final group = this;
    return group is FieldMemberGroup &&
        parsedGroup is FieldMemberGroup &&
        (!group.isLate || group.isLate == parsedGroup.isLate) &&
        (!group.isStatic || group.isStatic == parsedGroup.isStatic) &&
        (!group.isNullable || group.isNullable == parsedGroup.isNullable) &&
        (group.modifier == Modifier.unset ||
            group.modifier == parsedGroup.modifier) &&
        (group.keyword == FieldKeyword.unset ||
            group.keyword == parsedGroup.keyword) &&
        (group.annotation == Annotation.unset ||
            group.annotation == parsedGroup.annotation);
  }
}
