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

import 'package:analyzer/dart/ast/ast.dart' show FieldDeclaration;
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:solid_lints/lints/member_ordering/member_ordering_utils.dart';
import 'package:solid_lints/lints/member_ordering/models/annotation.dart';
import 'package:solid_lints/lints/member_ordering/models/field_keyword.dart';
import 'package:solid_lints/lints/member_ordering/models/member_group.dart';
import 'package:solid_lints/lints/member_ordering/models/member_type.dart';
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
