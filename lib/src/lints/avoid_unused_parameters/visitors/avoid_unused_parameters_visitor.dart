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
import 'package:collection/collection.dart';
import 'package:solid_lints/src/utils/node_utils.dart';
import 'package:solid_lints/src/utils/parameter_utils.dart';

/// AST Visitor which finds all is expressions and checks if they are
/// unrelated (result always false)
class AvoidUnusedParametersVisitor extends RecursiveAstVisitor<void> {
  final _unusedParameters = <FormalParameter>[];

  /// List of unused parameters
  Iterable<FormalParameter> get unusedParameters => _unusedParameters;

  @override
  void visitConstructorDeclaration(ConstructorDeclaration node) {
    super.visitConstructorDeclaration(node);

    final parent = node.parent;
    final parameters = node.parameters;

    if (parent is ClassDeclaration && parent.abstractKeyword != null ||
        node.externalKeyword != null ||
        parameters.parameters.isEmpty) {
      return;
    }
    final unused = _getUnusedParameters(
      node.body,
      parameters.parameters,
      initializers: node.initializers,
    ).whereNot(nameConsistsOfUnderscoresOnly);

    _unusedParameters.addAll(
      unused,
    );
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    super.visitMethodDeclaration(node);

    final parent = node.parent;
    final parameters = node.parameters;

    if (parent is ClassDeclaration && parent.abstractKeyword != null ||
        node.isAbstract ||
        node.externalKeyword != null ||
        (parameters == null || parameters.parameters.isEmpty)) {
      return;
    }

    final isTearOff = _usedAsTearOff(node);

    if (!isOverride(node.metadata) && !isTearOff) {
      _unusedParameters.addAll(
        _filterOutUnderscoresAndNamed(
          node.body,
          parameters.parameters,
        ),
      );
    }
  }

  @override
  void visitFunctionExpression(FunctionExpression node) {
    super.visitFunctionExpression(node);
    final params = node.parameters;
    if (params == null) {
      return;
    }

    _unusedParameters.addAll(
      _filterOutUnderscoresAndNamed(
        node.body,
        params.parameters,
      ),
    );
  }

  Iterable<FormalParameter> _filterOutUnderscoresAndNamed(
    AstNode body,
    Iterable<FormalParameter> parameters,
  ) {
    final unused = _getUnusedParameters(
      body,
      parameters,
    );
    return unused.whereNot(nameConsistsOfUnderscoresOnly).where(
          (param) => !param.isNamed,
        );
  }

  Set<FormalParameter> _getUnusedParameters(
    AstNode body,
    Iterable<FormalParameter> parameters, {
    NodeList<AstNode>? initializers,
  }) {
    final result = <FormalParameter>{};
    final visitor = _IdentifiersVisitor();
    body.visitChildren(visitor);
    initializers?.accept(visitor);

    final allIdentifierElements = visitor.elements;

    for (final parameter in parameters) {
      final name = parameter.name;
      final isPresentInAll = allIdentifierElements.contains(
        parameter.declaredElement,
      );

      /// Variables declared and initialized as 'Foo(this.param)'
      bool isFieldFormalParameter = parameter is FieldFormalParameter;

      /// Variables declared and initialized as 'Foo(super.param)'
      bool isSuperFormalParameter = parameter is SuperFormalParameter;

      if (parameter is DefaultFormalParameter) {
        /// Variables as 'Foo({super.param})' or 'Foo({this.param})'
        /// is being reported as [DefaultFormalParameter] instead
        /// of [SuperFormalParameter] it seems to be an issue in DartSDK
        isFieldFormalParameter = parameter.toSource().contains('this.');
        isSuperFormalParameter = parameter.toSource().contains('super.');
      }
      //

      if (name != null &&
          !isPresentInAll &&
          !isFieldFormalParameter &&
          !isSuperFormalParameter) {
        result.add(parameter);
      }
    }

    return result;
  }

  bool _usedAsTearOff(MethodDeclaration node) {
    final name = node.name.lexeme;
    if (!Identifier.isPrivateName(name)) {
      return false;
    }

    final visitor = _InvocationsVisitor(name);
    node.root.visitChildren(visitor);

    return visitor.hasTearOffInvocations;
  }
}

class _IdentifiersVisitor extends RecursiveAstVisitor<void> {
  final elements = <Element>{};

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    super.visitSimpleIdentifier(node);

    final element = node.staticElement;
    if (element != null) {
      elements.add(element);
    }
  }
}

class _InvocationsVisitor extends RecursiveAstVisitor<void> {
  final String methodName;

  bool hasTearOffInvocations = false;

  _InvocationsVisitor(this.methodName);

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    if (node.name == methodName &&
        node.staticElement is MethodElement &&
        node.parent is ArgumentList) {
      hasTearOffInvocations = true;
    }

    super.visitSimpleIdentifier(node);
  }
}
