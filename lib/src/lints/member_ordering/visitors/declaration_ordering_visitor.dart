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

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:collection/collection.dart';
import 'package:solid_lints/src/lints/member_ordering/models/member_group/constructor_member_group.dart';
import 'package:solid_lints/src/lints/member_ordering/models/member_group/field_member_group.dart';
import 'package:solid_lints/src/lints/member_ordering/models/member_group/get_set_member_group.dart';
import 'package:solid_lints/src/lints/member_ordering/models/member_group/member_group.dart';
import 'package:solid_lints/src/lints/member_ordering/models/member_group/method_member_group.dart';
import 'package:solid_lints/src/lints/member_ordering/models/member_info.dart';
import 'package:solid_lints/src/lints/member_ordering/models/member_names.dart';
import 'package:solid_lints/src/lints/member_ordering/models/member_order.dart';
import 'package:solid_lints/src/lints/member_ordering/models/member_ordering_parameters.dart';

/// Visitor for determining class member ordering.
class DeclarationOrderingVisitor {
  final bool _isFlutterWidget;
  final MemberOrderingParameters _parameters;

  /// Collected member info.
  final membersInfo = <MemberInfo>[];

  /// Creates instance of [DeclarationOrderingVisitor].
  DeclarationOrderingVisitor({
    required this._parameters,
    required this._isFlutterWidget,
  });

  /// Visits a [ClassMember].
  void visit(ClassMember member) => switch (member) {
    FieldDeclaration() => _visitFieldDeclaration(member),
    ConstructorDeclaration() => _visitConstructorDeclaration(member),
    MethodDeclaration() => _visitMethodDeclaration(member),
    _ => (),
  };

  void _visitFieldDeclaration(FieldDeclaration declaration) => _addMemberInfo(
    classMember: declaration,
    parsedGroup: FieldMemberGroup.parse(declaration),
    token: declaration.fields.variables.first.name,
    type: declaration.fields.type?.type?.getDisplayString() ?? '_',
  );

  void _visitConstructorDeclaration(ConstructorDeclaration declaration) =>
      _addMemberInfo(
        classMember: declaration,
        parsedGroup: ConstructorMemberGroup.parse(declaration),
        token: declaration.name,
        type: declaration.typeName?.name ?? '',
      );

  void _visitMethodDeclaration(MethodDeclaration declaration) {
    final group = (declaration.isGetter || declaration.isSetter)
        ? GetSetMemberGroup.parse(declaration)
        : MethodMemberGroup.parse(declaration);

    _addMemberInfo(
      classMember: declaration,
      parsedGroup: group,
      token: declaration.name,
      type: declaration.returnType?.type?.getDisplayString() ?? '_',
    );
  }

  void _addMemberInfo({
    required ClassMember classMember,
    required MemberGroup parsedGroup,
    required Token? token,
    required String type,
  }) {
    final closestGroup = _getClosestGroup(parsedGroup);
    if (closestGroup == null) return;

    membersInfo.add(
      MemberInfo(
        classMember: classMember,
        memberOrder: _getOrder(
          closestGroup,
          token?.lexeme ?? '',
          type,
        ),
      ),
    );
  }

  MemberGroup? _getClosestGroup(MemberGroup parsedGroup) {
    final closestGroups =
        (_isFlutterWidget
                ? _parameters.widgetsGroupsOrder
                : _parameters.groupsOrder)
            .where((group) => group.implies(parsedGroup))
            .sorted(
              (a, b) => b.getSortingCoefficient() - a.getSortingCoefficient(),
            );

    return closestGroups.firstOrNull;
  }

  MemberOrder _getOrder(
    MemberGroup memberGroup,
    String memberName,
    String typeName,
  ) {
    if (membersInfo.isEmpty) {
      return MemberOrder(
        memberNames: MemberNames(
          currentName: memberName,
          currentTypeName: typeName,
        ),
        isAlphabeticallyWrong: false,
        isByTypeWrong: false,
        memberGroup: memberGroup,
        isWrong: false,
      );
    }

    final lastMemberOrder = membersInfo.last.memberOrder;
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
      isAlphabeticallyWrong:
          hasSameGroup &&
          memberNames.currentName.compareTo(memberNames.previousName!) < 0,
      isByTypeWrong:
          hasSameGroup &&
          memberNames.currentTypeName.toLowerCase().compareTo(
                memberNames.previousTypeName!.toLowerCase(),
              ) <
              0,
      memberGroup: memberGroup,
      previousMemberGroup: previousMemberGroup,
      isWrong:
          (hasSameGroup && lastMemberOrder.isWrong) ||
          _isCurrentGroupBefore(
            lastMemberOrder.memberGroup,
            memberGroup,
          ),
    );
  }

  bool _isCurrentGroupBefore(
    MemberGroup lastMemberGroup,
    MemberGroup memberGroup,
  ) {
    final group = _isFlutterWidget
        ? _parameters.widgetsGroupsOrder
        : _parameters.groupsOrder;

    return group.indexOf(lastMemberGroup) > group.indexOf(memberGroup);
  }
}
