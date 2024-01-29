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

import 'package:analyzer/dart/ast/ast.dart' show Identifier, MethodDeclaration;
import 'package:solid_lints/src/lints/member_ordering/member_ordering_utils.dart';
import 'package:solid_lints/src/lints/member_ordering/models/annotation.dart';
import 'package:solid_lints/src/lints/member_ordering/models/member_group/member_group.dart';
import 'package:solid_lints/src/lints/member_ordering/models/member_type.dart';
import 'package:solid_lints/src/lints/member_ordering/models/modifier.dart';

/// Data class represents class method
class MethodMemberGroup extends MemberGroup {
  /// Shows if method is static member of a class
  final bool isStatic;

  /// Shows if method return type is nullable
  final bool isNullable;

  /// Represents method name
  final String? name;

  /// Creates instance of [MethodMemberGroup]
  const MethodMemberGroup({
    required this.isNullable,
    required this.isStatic,
    required this.name,
    required super.annotation,
    required super.memberType,
    required super.modifier,
    required super.rawRepresentation,
  });

  /// Named constructor to create an instance of [MethodMemberGroup] with name
  factory MethodMemberGroup.named({
    required String name,
    required MemberType memberType,
    required String rawRepresentation,
  }) =>
      MethodMemberGroup(
        name: name,
        isNullable: false,
        isStatic: false,
        modifier: Modifier.unset,
        annotation: Annotation.unset,
        memberType: memberType,
        rawRepresentation: rawRepresentation,
      );

  /// Parses [MethodDeclaration] and returns instance of [MethodMemberGroup]
  factory MethodMemberGroup.parse(MethodDeclaration declaration) {
    final methodName = declaration.name.lexeme;
    final annotation = parseAnnotation(declaration);
    final modifier = Identifier.isPrivateName(methodName)
        ? Modifier.private
        : Modifier.public;

    return MethodMemberGroup(
      name: methodName.toLowerCase(),
      annotation: annotation ?? Annotation.unset,
      isStatic: declaration.isStatic,
      isNullable: declaration.returnType?.question != null,
      memberType: MemberType.method,
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
    coefficient += name != null ? 10 : 0;

    return coefficient;
  }

  @override
  String toString() => rawRepresentation;
}
