// MIT License
//
// Copyright (c) 2020-2021 Dart Code Checker team
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import 'package:analyzer/dart/ast/ast.dart' hide Annotation;
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:collection/collection.dart';
import 'package:solid_lints/src/lints/member_ordering/models/annotation.dart';
import 'package:solid_lints/src/lints/member_ordering/models/field_keyword.dart';
import 'package:solid_lints/src/lints/member_ordering/models/member_group/constructor_member_group.dart';
import 'package:solid_lints/src/lints/member_ordering/models/member_group/field_member_group.dart';
import 'package:solid_lints/src/lints/member_ordering/models/member_group/get_set_member_group.dart';
import 'package:solid_lints/src/lints/member_ordering/models/member_group/member_group.dart';
import 'package:solid_lints/src/lints/member_ordering/models/member_group/method_member_group.dart';
import 'package:solid_lints/src/lints/member_ordering/models/member_type.dart';
import 'package:solid_lints/src/lints/member_ordering/models/modifier.dart';
import 'package:solid_lints/src/utils/types_utils.dart';

/// AST Visitor which finds all class members and checks if they are
/// in order provided from rule config or default config
class MemberOrderingVisitor extends RecursiveAstVisitor<List<MemberInfo>> {
  final List<MemberGroup> _groupsOrder;
  final List<MemberGroup> _widgetsGroupsOrder;

  final _membersInfo = <MemberInfo>[];

  /// Creates instance of [MemberOrderingVisitor]
  /// [_groupsOrder] config is used for regular classes
  /// [_widgetsGroupsOrder] config is used for widget classes
  MemberOrderingVisitor(this._groupsOrder, this._widgetsGroupsOrder);

  @override
  List<MemberInfo> visitClassDeclaration(ClassDeclaration node) {
    super.visitClassDeclaration(node);

    _membersInfo.clear();

    final type = node.extendsClause?.superclass.type;
    final isFlutterWidget =
        isWidgetOrSubclass(type) || isWidgetStateOrSubclass(type);

    for (final member in node.members) {
      if (member is FieldDeclaration) {
        _visitFieldDeclaration(member, isFlutterWidget);
      } else if (member is ConstructorDeclaration) {
        _visitConstructorDeclaration(member, isFlutterWidget);
      } else if (member is MethodDeclaration) {
        _visitMethodDeclaration(member, isFlutterWidget);
      }
    }

    return _membersInfo;
  }

  void _visitFieldDeclaration(
    FieldDeclaration declaration,
    bool isFlutterWidget,
  ) {
    final group = FieldMemberGroup.parse(declaration);
    final closestGroup = _getClosestGroup(group, isFlutterWidget);

    if (closestGroup != null) {
      _membersInfo.add(
        MemberInfo(
          classMember: declaration,
          memberOrder: _getOrder(
            closestGroup,
            declaration.fields.variables.first.name.lexeme,
            declaration.fields.type?.type?.getDisplayString() ?? '_',
            isFlutterWidget,
          ),
        ),
      );
    }
  }

  void _visitConstructorDeclaration(
    ConstructorDeclaration declaration,
    bool isFlutterWidget,
  ) {
    final group = ConstructorMemberGroup.parse(declaration);
    final closestGroup = _getClosestGroup(group, isFlutterWidget);

    if (closestGroup != null) {
      _membersInfo.add(
        MemberInfo(
          classMember: declaration,
          memberOrder: _getOrder(
            closestGroup,
            declaration.name?.lexeme ?? '',
            declaration.returnType.name,
            isFlutterWidget,
          ),
        ),
      );
    }
  }

  void _visitMethodDeclaration(
    MethodDeclaration declaration,
    bool isFlutterWidget,
  ) {
    if (declaration.isGetter || declaration.isSetter) {
      final group = GetSetMemberGroup.parse(declaration);
      final closestGroup = _getClosestGroup(group, isFlutterWidget);

      if (closestGroup != null) {
        _membersInfo.add(
          MemberInfo(
            classMember: declaration,
            memberOrder: _getOrder(
              closestGroup,
              declaration.name.lexeme,
              declaration.returnType?.type?.getDisplayString() ?? '_',
              isFlutterWidget,
            ),
          ),
        );
      }
    } else {
      final group = MethodMemberGroup.parse(declaration);
      final closestGroup = _getClosestGroup(group, isFlutterWidget);

      if (closestGroup != null) {
        _membersInfo.add(
          MemberInfo(
            classMember: declaration,
            memberOrder: _getOrder(
              closestGroup,
              declaration.name.lexeme,
              declaration.returnType?.type?.getDisplayString() ?? '_',
              isFlutterWidget,
            ),
          ),
        );
      }
    }
  }

  MemberGroup? _getClosestGroup(
    MemberGroup parsedGroup,
    bool isFlutterWidget,
  ) {
    final closestGroups = (isFlutterWidget ? _widgetsGroupsOrder : _groupsOrder)
        .where(
          (group) =>
              _isConstructorGroup(group, parsedGroup) ||
              _isFieldGroup(group, parsedGroup) ||
              _isGetSetGroup(group, parsedGroup) ||
              _isMethodGroup(group, parsedGroup),
        )
        .sorted(
          (a, b) => b.getSortingCoefficient() - a.getSortingCoefficient(),
        );

    return closestGroups.firstOrNull;
  }

  MemberOrder _getOrder(
    MemberGroup memberGroup,
    String memberName,
    String typeName,
    bool isFlutterWidget,
  ) {
    if (_membersInfo.isNotEmpty) {
      final lastMemberOrder = _membersInfo.last.memberOrder;
      final hasSameGroup = lastMemberOrder.memberGroup == memberGroup;

      final previousMemberGroup =
          hasSameGroup && lastMemberOrder.previousMemberGroup != null
              ? lastMemberOrder.previousMemberGroup
              : lastMemberOrder.memberGroup;

      final memberNames = MemberNames(
        currentName: memberName,
        previousName: lastMemberOrder.memberNames.currentName,
        currentTypeName: typeName,
        previousTypeName: lastMemberOrder.memberNames.currentTypeName,
      );

      return MemberOrder(
        memberNames: memberNames,
        isAlphabeticallyWrong: hasSameGroup &&
            memberNames.currentName.compareTo(memberNames.previousName!) < 0,
        isByTypeWrong: hasSameGroup &&
            memberNames.currentTypeName
                    .toLowerCase()
                    .compareTo(memberNames.previousTypeName!.toLowerCase()) <
                0,
        memberGroup: memberGroup,
        previousMemberGroup: previousMemberGroup,
        isWrong: (hasSameGroup && lastMemberOrder.isWrong) ||
            _isCurrentGroupBefore(
              lastMemberOrder.memberGroup,
              memberGroup,
              isFlutterWidget,
            ),
      );
    }

    return MemberOrder(
      memberNames:
          MemberNames(currentName: memberName, currentTypeName: typeName),
      isAlphabeticallyWrong: false,
      isByTypeWrong: false,
      memberGroup: memberGroup,
      isWrong: false,
    );
  }

  bool _isCurrentGroupBefore(
    MemberGroup lastMemberGroup,
    MemberGroup memberGroup,
    bool isFlutterWidget,
  ) {
    final group = isFlutterWidget ? _widgetsGroupsOrder : _groupsOrder;

    return group.indexOf(lastMemberGroup) > group.indexOf(memberGroup);
  }

  bool _isConstructorGroup(MemberGroup group, MemberGroup parsedGroup) =>
      group is ConstructorMemberGroup &&
      parsedGroup is ConstructorMemberGroup &&
      (!group.isFactory || group.isFactory == parsedGroup.isFactory) &&
      (!group.isNamed || group.isNamed == parsedGroup.isNamed) &&
      (group.modifier == Modifier.unset ||
          group.modifier == parsedGroup.modifier) &&
      (group.annotation == Annotation.unset ||
          group.annotation == parsedGroup.annotation);

  bool _isMethodGroup(MemberGroup group, MemberGroup parsedGroup) =>
      group is MethodMemberGroup &&
      parsedGroup is MethodMemberGroup &&
      (!group.isStatic || group.isStatic == parsedGroup.isStatic) &&
      (!group.isNullable || group.isNullable == parsedGroup.isNullable) &&
      (group.name == null || group.name == parsedGroup.name) &&
      (group.modifier == Modifier.unset ||
          group.modifier == parsedGroup.modifier) &&
      (group.annotation == Annotation.unset ||
          group.annotation == parsedGroup.annotation);

  bool _isGetSetGroup(MemberGroup group, MemberGroup parsedGroup) =>
      group is GetSetMemberGroup &&
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

  bool _isFieldGroup(MemberGroup group, MemberGroup parsedGroup) =>
      group is FieldMemberGroup &&
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

/// Data class that holds AST class member and it's order info
class MemberInfo {
  /// AST instance of an [ClassMember]
  final ClassMember classMember;

  /// Class member order info
  final MemberOrder memberOrder;

  /// Creates instance of an [MemberInfo]
  const MemberInfo({
    required this.classMember,
    required this.memberOrder,
  });
}

/// Data class holds information about class member order info
class MemberOrder {
  /// Indicates if order is wrong
  final bool isWrong;

  /// Indicates if order is wrong alphabetically
  final bool isAlphabeticallyWrong;

  /// Indicates if order is wrong alphabetically by type
  final bool isByTypeWrong;

  /// Info about current and previous class member name
  final MemberNames memberNames;

  /// Info about current member member group
  final MemberGroup memberGroup;

  /// Info about previous member member group
  final MemberGroup? previousMemberGroup;

  /// Creates instance of [MemberOrder]
  const MemberOrder({
    required this.isWrong,
    required this.isAlphabeticallyWrong,
    required this.isByTypeWrong,
    required this.memberNames,
    required this.memberGroup,
    this.previousMemberGroup,
  });
}

/// Data class contains info about current and previous class member names
class MemberNames {
  /// Name of current class member
  final String currentName;

  /// Name of previous class member
  final String? previousName;

  /// Type name of current class member
  final String currentTypeName;

  /// Type name of previous class member
  final String? previousTypeName;

  /// Crates instance of [MemberNames]
  const MemberNames({
    required this.currentName,
    required this.currentTypeName,
    this.previousName,
    this.previousTypeName,
  });
}
