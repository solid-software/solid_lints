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

/// AST Visitor which finds all setState invocations and checks if they are
/// necessary
class AvoidUnnecessarySetStateMethodVisitor extends RecursiveAstVisitor<void> {
  final Set<String> _classMethodsNames;
  final Set<FunctionBody> _classMethodBodies;

  final _setStateInvocations = <MethodInvocation>[];
  final _classMethodsInvocations = <MethodInvocation>[];

  /// Invocations of setState within visited methods.
  Iterable<MethodInvocation> get setStateInvocations => _setStateInvocations;

  /// Invocations of methods within visited methods.
  Iterable<MethodInvocation> get classMethodsInvocations =>
      _classMethodsInvocations;

  ///
  AvoidUnnecessarySetStateMethodVisitor(
    this._classMethodsNames,
    this._classMethodBodies,
  );

  @override
  void visitMethodInvocation(MethodInvocation node) {
    super.visitMethodInvocation(node);

    final name = node.methodName.name;
    final isNotInCallback = !_isInCallback(node);

    if (name == 'setState' && isNotInCallback) {
      _setStateInvocations.add(node);
      return;
    }
    final isClassMethod = _classMethodsNames.contains(name);
    final isReturnValueUsed = node.realTarget != null;

    if (isClassMethod && isNotInCallback && !isReturnValueUsed) {
      _classMethodsInvocations.add(node);
    }
  }

  bool _isInCallback(MethodInvocation node) =>
      node.thisOrAncestorMatching(
        (parent) =>
            parent is FunctionBody && !_classMethodBodies.contains(parent),
      ) !=
      null;
}
