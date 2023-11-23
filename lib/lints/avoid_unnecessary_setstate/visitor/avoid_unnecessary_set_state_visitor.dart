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
import 'package:solid_lints/lints/avoid_unnecessary_setstate/visitor/avoid_unnecessary_set_state_method_visitor.dart';
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

  /// All setState invocations in checkedMethods
  Iterable<MethodInvocation> get setStateInvocations => _setStateInvocations;

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    super.visitClassDeclaration(node);

    final type = node.extendsClause?.superclass.type;
    if (type == null || !isWidgetStateOrSubclass(type)) {
      return;
    }

    final declarations = node.members.whereType<MethodDeclaration>();
    final classMethodsCallingSetState = declarations
        .where(_hasSetStateInvocation)
        // allow asynchronous triggers
        .where((d) => !d.body.isAsynchronous)
        .map((declaration) => declaration.name.lexeme)
        .toSet();
    final bodies = declarations.map((declaration) => declaration.body).toSet();
    final methods = declarations
        .where((member) => _checkedMethods.contains(member.name.lexeme))
        .toList();

    for (final method in methods) {
      final visitor = AvoidUnnecessarySetStateMethodVisitor(
        classMethodsCallingSetState,
        bodies,
      );
      method.visitChildren(visitor);

      _setStateInvocations.addAll([
        ...visitor.setStateInvocations,
      ]);
    }
  }

  bool _hasSetStateInvocation(MethodDeclaration node) {
    final visitor = _HasSetStateMethodVisitor();
    node.visitChildren(visitor);
    return visitor.hasSetStateCalls;
  }
}

class _HasSetStateMethodVisitor extends RecursiveAstVisitor<void> {
  bool _hasSetStateCalls = false;

  bool get hasSetStateCalls => _hasSetStateCalls;

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.methodName.name == 'setState') {
      _hasSetStateCalls = true;
    }
    super.visitMethodInvocation(node);
  }
}
