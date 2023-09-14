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

import 'package:analyzer/dart/ast/ast.dart' show ConstructorDeclaration;
import 'package:solid_lints/lints/member_ordering/models/annotation.dart';
import 'package:solid_lints/lints/member_ordering/models/member_group.dart';
import 'package:solid_lints/lints/member_ordering/models/member_type.dart';
import 'package:solid_lints/lints/member_ordering/member_ordering_utils.dart';
import 'package:solid_lints/lints/member_ordering/models/modifier.dart';

/// Data class represents class constructor
class ConstructorMemberGroup extends MemberGroup {
  /// Shows if constructor is named
  final bool isNamed;

  /// Shows if constructor is factory constructor
  final bool isFactory;

  /// Creates instance of [ConstructorMemberGroup]
  const ConstructorMemberGroup({
    required this.isNamed,
    required this.isFactory,
    required super.annotation,
    required super.memberType,
    required super.modifier,
    required super.rawRepresentation,
  });

  /// Parses instance of [ConstructorDeclaration]
  /// and returns [ConstructorMemberGroup]
  factory ConstructorMemberGroup.parse(ConstructorDeclaration declaration) {
    final annotation = parseAnnotation(declaration);
    final name = declaration.name;
    final isFactory = declaration.factoryKeyword != null;
    final isNamed = name != null;

    final modifier = parseModifier(name?.lexeme);

    return ConstructorMemberGroup(
      isNamed: isNamed,
      isFactory: isFactory,
      annotation: annotation ?? Annotation.unset,
      modifier: modifier,
      memberType: MemberType.constructor,
      rawRepresentation: '',
    );
  }

  @override
  int getSortingCoefficient() {
    var coefficient = 0;

    coefficient += isNamed ? 1 : 0;
    coefficient += isFactory ? 1 : 0;
    coefficient += annotation != Annotation.unset ? 1 : 0;
    coefficient += modifier != Modifier.unset ? 1 : 0;

    return coefficient;
  }

  @override
  String toString() => rawRepresentation;
}
