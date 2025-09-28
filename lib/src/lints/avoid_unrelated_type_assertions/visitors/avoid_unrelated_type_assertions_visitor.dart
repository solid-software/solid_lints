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
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:collection/collection.dart';

/// AST Visitor which finds all is expressions and checks if they are
/// unrelated (result always false)
class AvoidUnrelatedTypeAssertionsVisitor extends RecursiveAstVisitor<void> {
  final _expressions = <IsExpression, bool>{};

  /// Map of unrelated type checks and their results
  Map<IsExpression, bool> get expressions => _expressions;

  @override
  void visitIsExpression(IsExpression node) {
    super.visitIsExpression(node);

    final castedType = node.type.type;
    if (castedType is TypeParameterType) {
      return;
    }

    final objectType = node.expression.staticType;

    if (_isUnrelatedTypeCheck(objectType, castedType)) {
      _expressions[node] = node.notOperator != null;
    }
  }

  bool _isUnrelatedTypeCheck(DartType? objectType, DartType? castedType) {
    if (objectType == null || castedType == null) {
      return false;
    }

    if (objectType is DynamicType || castedType is DynamicType) {
      return false;
    }

    if (objectType is! ParameterizedType || castedType is! ParameterizedType) {
      return false;
    }

    final objectCastedType = _foundCastedTypeInObjectTypeHierarchy(
      objectType,
      castedType,
    );
    final castedObjectType = _foundCastedTypeInObjectTypeHierarchy(
      castedType,
      objectType,
    );
    if (objectCastedType == null && castedObjectType == null) {
      return true;
    }

    if (objectCastedType == null || castedObjectType == null) {
      return false;
    }

    if (_checkGenerics(objectCastedType, castedType) &&
        _checkGenerics(castedObjectType, objectType)) {
      return true;
    }

    return false;
  }

  DartType? _foundCastedTypeInObjectTypeHierarchy(
    DartType objectType,
    DartType castedType,
  ) {
    if (_isFutureOrAndFuture(objectType, castedType)) {
      return objectType;
    }

    final correctObjectType =
        objectType is InterfaceType && objectType.isDartAsyncFutureOr
            ? objectType.typeArguments.first
            : objectType;

    if ((correctObjectType.element == castedType.element) ||
        castedType is DynamicType ||
        correctObjectType is DynamicType ||
        _isObjectAndEnum(correctObjectType, castedType)) {
      return correctObjectType;
    }

    if (correctObjectType is InterfaceType) {
      return correctObjectType.allSupertypes.firstWhereOrNull(
        (value) => value.element == castedType.element,
      );
    }

    return null;
  }

  bool _checkGenerics(DartType objectType, DartType castedType) {
    if (objectType is DynamicType || castedType is DynamicType) {
      return false;
    }

    if (objectType is! ParameterizedType || castedType is! ParameterizedType) {
      return false;
    }

    final length = objectType.typeArguments.length;
    if (length != castedType.typeArguments.length) {
      return false;
    }

    for (var argumentIndex = 0; argumentIndex < length; argumentIndex++) {
      final objectGenericType = objectType.typeArguments[argumentIndex];
      final castedGenericType = castedType.typeArguments[argumentIndex];

      if (_isUnrelatedTypeCheck(objectGenericType, castedGenericType) &&
          _isUnrelatedTypeCheck(castedGenericType, objectGenericType)) {
        return true;
      }
    }

    return false;
  }

  bool _isFutureOrAndFuture(DartType objectType, DartType castedType) =>
      objectType.isDartAsyncFutureOr && castedType.isDartAsyncFuture;

  bool _isObjectAndEnum(DartType objectType, DartType castedType) =>
      objectType.isDartCoreObject &&
      castedType.element?.kind == ElementKind.ENUM;
}
