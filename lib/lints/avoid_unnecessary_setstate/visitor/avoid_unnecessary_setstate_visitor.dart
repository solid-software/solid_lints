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
import 'package:solid_lints/utils/types_utils.dart';

/// AST visitor which checks if class is State, in case yes checks its methods
class AvoidUnnecessarySetStateVisitor extends RecursiveAstVisitor<void> {
  static const _checkedMethods = [
    'initState',
    'didUpdateWidget',
    'didChangeDependencies',
    'build',
  ];

  final _setStateInvocations = <MethodInvocation>[];
  final _classMethodsInvocations = <MethodInvocation>[];

  /// All setState invocations in checkedMethods
  Iterable<MethodInvocation> get setStateInvocations => _setStateInvocations;

  /// All class methods invocations
  Iterable<MethodInvocation> get classMethodsInvocations =>
      _classMethodsInvocations;

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    super.visitClassDeclaration(node);

    final type = node.extendsClause?.superclass.type;
    if (type == null || !isWidgetStateOrSubclass(type)) {
      return;
    }

    final declarations = node.members.whereType<MethodDeclaration>().toList();
    final classMethodsNames =
        declarations.map((declaration) => declaration.name.lexeme).toSet();
    final bodies = declarations.map((declaration) => declaration.body).toList();
    final methods = declarations
        .where((member) => _checkedMethods.contains(member.name.lexeme))
        .toList();
    final restMethods = declarations
        .where((member) => !_checkedMethods.contains(member.name.lexeme))
        .toList();

    final visitedRestMethods = <String, bool>{};

    for (final method in methods) {
      final visitor = _MethodVisitor(classMethodsNames, bodies);
      method.visitChildren(visitor);

      _setStateInvocations.addAll(visitor.setStateInvocations);
      _classMethodsInvocations.addAll(
        visitor.classMethodsInvocations
            .where(
              (invocation) => _containsSetState(
                visitedRestMethods,
                classMethodsNames,
                bodies,
                restMethods.firstWhere(
                  (method) => method.name.lexeme == invocation.methodName.name,
                ),
              ),
            )
            .toList(),
      );
    }
  }

  bool _containsSetState(
    Map<String, bool> visitedRestMethods,
    Set<String> classMethodsNames,
    Iterable<FunctionBody> bodies,
    MethodDeclaration declaration,
  ) {
    final type = declaration.returnType?.type;
    if (type != null && (type.isDartAsyncFuture || type.isDartAsyncFutureOr)) {
      return false;
    }

    final name = declaration.name.lexeme;
    if (visitedRestMethods.containsKey(name) && visitedRestMethods[name]!) {
      return true;
    }

    final visitor = _MethodVisitor(classMethodsNames, bodies);
    declaration.visitChildren(visitor);

    final hasSetState = visitor.setStateInvocations.isNotEmpty;

    visitedRestMethods[name] = hasSetState;

    return hasSetState;
  }
}

/// AST Visitor which finds all setState invocations and checks if they are
/// necessary
class _MethodVisitor extends RecursiveAstVisitor<void> {
  final Set<String> classMethodsNames;
  final Iterable<FunctionBody> bodies;

  final _setStateInvocations = <MethodInvocation>[];
  final _classMethodsInvocations = <MethodInvocation>[];

  Iterable<MethodInvocation> get setStateInvocations => _setStateInvocations;
  Iterable<MethodInvocation> get classMethodsInvocations =>
      _classMethodsInvocations;

  _MethodVisitor(this.classMethodsNames, this.bodies);

  @override
  void visitMethodInvocation(MethodInvocation node) {
    super.visitMethodInvocation(node);

    final name = node.methodName.name;
    final notInBody = _isNotInFunctionBody(node);

    if (name == 'setState' && notInBody) {
      _setStateInvocations.add(node);
    } else if (classMethodsNames.contains(name) &&
        notInBody &&
        node.realTarget == null) {
      _classMethodsInvocations.add(node);
    }
  }

  bool _isNotInFunctionBody(MethodInvocation node) =>
      node.thisOrAncestorMatching(
        (parent) => parent is FunctionBody && !bodies.contains(parent),
      ) ==
      null;
}
