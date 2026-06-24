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
import 'package:analyzer/error/error.dart';
import 'package:collection/collection.dart';
import 'package:solid_lints/src/lints/member_ordering/member_ordering_rule.dart';
import 'package:solid_lints/src/lints/member_ordering/models/member_group/constructor_member_group.dart';
import 'package:solid_lints/src/lints/member_ordering/models/member_group/field_member_group.dart';
import 'package:solid_lints/src/lints/member_ordering/models/member_group/get_set_member_group.dart';
import 'package:solid_lints/src/lints/member_ordering/models/member_group/member_group.dart';
import 'package:solid_lints/src/lints/member_ordering/models/member_group/member_group_extensions.dart';
import 'package:solid_lints/src/lints/member_ordering/models/member_group/method_member_group.dart';
import 'package:solid_lints/src/lints/member_ordering/models/member_info.dart';
import 'package:solid_lints/src/lints/member_ordering/models/member_names.dart';
import 'package:solid_lints/src/lints/member_ordering/models/member_order.dart';
import 'package:solid_lints/src/lints/member_ordering/models/member_ordering_parameters.dart';
import 'package:solid_lints/src/utils/types_utils.dart';

/// AST Visitor which finds all class members and checks if they are
/// in order provided from rule config or default config
class MemberOrderingVisitor extends SimpleAstVisitor<void> {
  final MemberOrderingRule _rule;
  final MemberOrderingParameters _parameters;

  final _membersInfo = <MemberInfo>[];

  /// Creates instance of [MemberOrderingVisitor]
  MemberOrderingVisitor(this._rule, this._parameters);

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    super.visitClassDeclaration(node);

    _membersInfo.clear();

    final type = node.extendsClause?.superclass.type;
    final isFlutterWidget =
        isWidgetOrSubclass(type) || isWidgetStateOrSubclass(type);

    final body = node.body;
    if (body is BlockClassBody) {
      for (final member in body.members) {
        switch (member) {
          case FieldDeclaration():
            _visitFieldDeclaration(member, isFlutterWidget);
          case ConstructorDeclaration():
            _visitConstructorDeclaration(member, isFlutterWidget);
          case MethodDeclaration():
            _visitMethodDeclaration(member, isFlutterWidget);
          default:
        }
      }
    }

    _reportWrongOrder();

    if (_parameters.alphabetize) {
      _reportAlphabeticalOrder();
    } else if (_parameters.alphabetizeByType) {
      _reportAlphabeticalTypeOrder();
    }
  }

  void _reportWrongOrder() {
    _reportMembers(
      (info) => info.memberOrder.isWrong,
      MemberOrderingRule.wrongOrderCode,
      (info) => [
        info.memberOrder.memberGroup.toString(),
        info.memberOrder.previousMemberGroup?.toString() ?? '',
      ],
    );
  }

  void _reportAlphabeticalOrder() {
    _reportMembers(
      (info) => info.memberOrder.isAlphabeticallyWrong,
      MemberOrderingRule.alphabeticalOrderCode,
      (info) => [
        info.memberOrder.memberNames.currentName,
        info.memberOrder.memberNames.previousName ?? '',
      ],
    );
  }

  void _reportAlphabeticalTypeOrder() {
    _reportMembers(
      (info) => info.memberOrder.isByTypeWrong,
      MemberOrderingRule.alphabeticalByTypeOrderCode,
      (info) => [
        info.memberOrder.memberNames.currentTypeName,
        info.memberOrder.memberNames.previousTypeName ?? '',
      ],
    );
  }

  void _reportMembers(
    bool Function(MemberInfo) filter,
    LintCode code,
    List<String> Function(MemberInfo) getArguments,
  ) {
    final filtered = _membersInfo.where(filter);

    for (final memberInfo in filtered) {
      _rule.reportAtNode(
        memberInfo.classMember,
        diagnosticCode: code,
        arguments: getArguments(memberInfo),
      );
    }
  }

  void _visitFieldDeclaration(
    FieldDeclaration declaration,
    bool isFlutterWidget,
  ) {
    _addMemberInfo(
      classMember: declaration,
      parsedGroup: FieldMemberGroup.parse(declaration),
      isFlutterWidget: isFlutterWidget,
      name: declaration.fields.variables.first.name.lexeme,
      type: declaration.fields.type?.type?.getDisplayString() ?? '_',
    );
  }

  void _visitConstructorDeclaration(
    ConstructorDeclaration declaration,
    bool isFlutterWidget,
  ) {
    _addMemberInfo(
      classMember: declaration,
      parsedGroup: ConstructorMemberGroup.parse(declaration),
      isFlutterWidget: isFlutterWidget,
      name: declaration.name?.lexeme ?? '',
      type: declaration.typeName?.name ?? '',
    );
  }

  void _visitMethodDeclaration(
    MethodDeclaration declaration,
    bool isFlutterWidget,
  ) {
    final group = (declaration.isGetter || declaration.isSetter)
        ? GetSetMemberGroup.parse(declaration)
        : MethodMemberGroup.parse(declaration);

    _addMemberInfo(
      classMember: declaration,
      parsedGroup: group,
      isFlutterWidget: isFlutterWidget,
      name: declaration.name.lexeme,
      type: declaration.returnType?.type?.getDisplayString() ?? '_',
    );
  }

  void _addMemberInfo({
    required ClassMember classMember,
    required MemberGroup parsedGroup,
    required bool isFlutterWidget,
    required String name,
    required String type,
  }) {
    final closestGroup = _getClosestGroup(parsedGroup, isFlutterWidget);

    if (closestGroup != null) {
      _membersInfo.add(
        MemberInfo(
          classMember: classMember,
          memberOrder: _getOrder(
            closestGroup,
            name,
            type,
            isFlutterWidget,
          ),
        ),
      );
    }
  }

  MemberGroup? _getClosestGroup(
    MemberGroup parsedGroup,
    bool isFlutterWidget,
  ) {
    final closestGroups =
        (isFlutterWidget
                ? _parameters.widgetsGroupsOrder
                : _parameters.groupsOrder)
            .where((group) => group.satisfies(parsedGroup))
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
              isFlutterWidget,
            ),
      );
    }

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

  bool _isCurrentGroupBefore(
    MemberGroup lastMemberGroup,
    MemberGroup memberGroup,
    bool isFlutterWidget,
  ) {
    final group = isFlutterWidget
        ? _parameters.widgetsGroupsOrder
        : _parameters.groupsOrder;

    return group.indexOf(lastMemberGroup) > group.indexOf(memberGroup);
  }
}
