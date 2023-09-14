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

import 'package:collection/collection.dart';
import 'package:solid_lints/lints/member_ordering/models/annotation.dart';
import 'package:solid_lints/lints/member_ordering/models/constructor_member_group.dart';
import 'package:solid_lints/lints/member_ordering/models/field_keyword.dart';
import 'package:solid_lints/lints/member_ordering/models/field_member_group.dart';
import 'package:solid_lints/lints/member_ordering/models/get_set_member_group.dart';
import 'package:solid_lints/lints/member_ordering/models/member_group.dart';
import 'package:solid_lints/lints/member_ordering/models/member_type.dart';
import 'package:solid_lints/lints/member_ordering/models/method_member_group.dart';
import 'package:solid_lints/lints/member_ordering/models/modifier.dart';

/// Helper class to parse member-ordering rule config
class MemberOrderingConfigParser {
  static const _defaultOrderList = [
    'public-fields',
    'private-fields',
    'public-getters',
    'private-getters',
    'public-setters',
    'private-setters',
    'constructors',
    'public-methods',
    'private-methods',
  ];

  static const _defaultWidgetsOrderList = [
    'constructor',
    'named-constructor',
    'const-fields',
    'static-methods',
    'final-fields',
    'init-state-method',
    'var-fields',
    'init-state-method',
    'private-methods',
    'overridden-public-methods',
    'build-method',
  ];

  static final _regExp = RegExp(
    '(overridden-|protected-)?(private-|public-)?(static-)?(late-)?'
    '(var-|final-|const-)?(nullable-)?(named-)?(factory-)?',
  );

  /// Parse rule config for regular class order rules
  static List<MemberGroup> parseOrder(Object? orderConfig) {
    final order = orderConfig is Iterable
        ? List<String>.from(orderConfig)
        : _defaultOrderList;

    return order.map(_parseGroup).whereNotNull().toList();
  }

  /// Parse rule config for widget class order rules
  static List<MemberGroup> parseWidgetsOrder(Object? widgetsOrderConfig) {
    final widgetsOrder = widgetsOrderConfig is Iterable
        ? List<String>.from(widgetsOrderConfig)
        : _defaultWidgetsOrderList;

    return widgetsOrder.map(_parseGroup).whereNotNull().toList();
  }

  static MemberGroup? _parseGroup(String group) {
    final lastGroup = group.endsWith('getters-setters')
        ? 'getters-setters'
        : group.split('-').lastOrNull;
    final type = MemberType.parse(lastGroup);
    final result = _regExp.allMatches(group.toLowerCase());

    final isNamedMethod = group.endsWith('-method');
    if (isNamedMethod) {
      final name = group.split('-method').first.replaceAll('-', '');

      return MethodMemberGroup.named(
        name: name,
        memberType: MemberType.method,
        rawRepresentation: group,
      );
    }

    final hasGroups = result.isNotEmpty && result.first.groupCount > 0;
    if (hasGroups && type != null) {
      final match = result.first;

      final annotation = Annotation.parse(match.group(1)?.replaceAll('-', ''));
      final modifier = Modifier.parse(match.group(2)?.replaceAll('-', ''));
      final isStatic = match.group(3) != null;
      final isLate = match.group(4) != null;
      final keyword = FieldKeyword.parse(match.group(5)?.replaceAll('-', ''));
      final isNullable = match.group(6) != null;
      final isNamed = match.group(7) != null;
      final isFactory = match.group(8) != null;

      switch (type) {
        case MemberType.field:
          return FieldMemberGroup(
            isLate: isLate,
            isNullable: isNullable,
            isStatic: isStatic,
            keyword: keyword,
            annotation: annotation,
            memberType: type,
            modifier: modifier,
            rawRepresentation: group,
          );

        case MemberType.method:
          return MethodMemberGroup(
            name: null,
            isNullable: isNullable,
            isStatic: isStatic,
            annotation: annotation,
            memberType: type,
            modifier: modifier,
            rawRepresentation: group,
          );

        case MemberType.getter:
        case MemberType.setter:
        case MemberType.getterAndSetter:
          return GetSetMemberGroup(
            isNullable: isNullable,
            isStatic: isStatic,
            annotation: annotation,
            memberType: type,
            modifier: modifier,
            rawRepresentation: group,
          );

        case MemberType.constructor:
          return ConstructorMemberGroup(
            isNamed: isFactory || isNamed,
            isFactory: isFactory,
            annotation: annotation,
            memberType: type,
            modifier: modifier,
            rawRepresentation: group,
          );
      }
    }

    return null;
  }
}
