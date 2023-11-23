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
  final Set<String> _classMethodsCallingSetState;
  final Set<FunctionBody> _bodies;

  final _setStateInvocations = <MethodInvocation>[];

  /// All setState invocations
  Iterable<MethodInvocation> get setStateInvocations => _setStateInvocations;

  /// Constructor for AvoidUnnecessarySetStateMethodVisitor
  AvoidUnnecessarySetStateMethodVisitor(
    this._classMethodsCallingSetState,
    this._bodies,
  );

  @override
  void visitMethodInvocation(MethodInvocation node) {
    super.visitMethodInvocation(node);

    final name = node.methodName.name;
    final notInBody = _isNotInFunctionBody(node);

    if (name == 'setState' && notInBody) {
      _setStateInvocations.add(node);
      return;
    }

    final isClassMethodCallingSetState =
        _classMethodsCallingSetState.contains(name);
    final isReturnValueUsed = node.realTarget != null;

    if (isClassMethodCallingSetState && notInBody && !isReturnValueUsed) {
      _setStateInvocations.add(node);
    }
  }

  bool _isNotInFunctionBody(MethodInvocation node) =>
      node.thisOrAncestorMatching(
        (parent) => parent is FunctionBody && !_bodies.contains(parent),
      ) ==
      null;
}
