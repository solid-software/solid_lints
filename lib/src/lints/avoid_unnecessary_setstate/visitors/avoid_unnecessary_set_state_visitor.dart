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
import 'package:collection/collection.dart';
import 'package:solid_lints/src/lints/avoid_unnecessary_setstate/visitors/avoid_unnecessary_set_state_method_visitor.dart';
import 'package:solid_lints/src/utils/types_utils.dart';

/// AST visitor which checks if class is State, in case yes checks its methods
class AvoidUnnecessarySetStateVisitor extends RecursiveAstVisitor<void> {
  static const _checkedMethods = [
    'initState',
    'didUpdateWidget',
    'didChangeDependencies',
    'build',
  ];

  final _setStateInvocations = <MethodInvocation>[];

  /// Unnecessary setState invocations
  Iterable<MethodInvocation> get setStateInvocations => _setStateInvocations;

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    super.visitClassDeclaration(node);

    final type = node.extendsClause?.superclass.type;
    if (type == null || !isWidgetStateOrSubclass(type)) {
      return;
    }

    final methods = node.members.whereType<MethodDeclaration>();
    final classMethodsNames = methods
        .map((declaration) => declaration.name.lexeme)
        .toSet();
    final methodBodies = methods.map((declaration) => declaration.body).toSet();

    final checkedMethods = methods.where(_isMethodChecked);
    final uncheckedMethods = methods.whereNot(_isMethodChecked);

    // memo for visited methods; prevents checking the same method twice
    final methodToHasSetState = <String, bool>{};

    for (final method in checkedMethods) {
      final visitor = AvoidUnnecessarySetStateMethodVisitor(
        classMethodsNames,
        methodBodies,
      );
      method.visitChildren(visitor);

      _setStateInvocations.addAll(visitor.setStateInvocations);
      _setStateInvocations.addAll(
        visitor.classMethodsInvocations
            .where(
              (invocation) => _containsSetState(
                methodToHasSetState,
                classMethodsNames,
                methodBodies,
                uncheckedMethods.firstWhere(
                  (method) => method.name.lexeme == invocation.methodName.name,
                ),
              ),
            )
            .toList(),
      );
    }
  }

  bool _isMethodChecked(MethodDeclaration m) =>
      _checkedMethods.contains(m.name.lexeme);

  bool _containsSetState(
    Map<String, bool> methodToHasSetState,
    Set<String> classMethodsNames,
    Set<FunctionBody> bodies,
    MethodDeclaration declaration,
  ) {
    final type = declaration.returnType?.type;
    if (type != null && (type.isDartAsyncFuture || type.isDartAsyncFutureOr)) {
      return false;
    }

    final name = declaration.name.lexeme;
    if (methodToHasSetState.containsKey(name) && methodToHasSetState[name]!) {
      return true;
    }

    final visitor = AvoidUnnecessarySetStateMethodVisitor(
      classMethodsNames,
      bodies,
    );
    declaration.visitChildren(visitor);

    final hasSetState = visitor.setStateInvocations.isNotEmpty;

    methodToHasSetState[name] = hasSetState;

    return hasSetState;
  }
}
