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
import 'package:solid_lints/src/lints/named_parameters_ordering/models/parameter_type.dart';
import 'package:solid_lints/src/lints/named_parameters_ordering/named_parameters_ordering_rule.dart';

/// AST Visitor which finds all methods, functions and constructor named
/// parameters and checks if they are in order provided from rule config
/// or default config.
class NamedParametersOrderingVisitor extends SimpleAstVisitor<void> {
  final NamedParametersOrderingRule _rule;
  final List<ParameterType> _parametersOrder;

  /// Creates instance of [NamedParametersOrderingVisitor]
  NamedParametersOrderingVisitor(this._rule, this._parametersOrder);

  @override
  void visitFormalParameterList(FormalParameterList node) {
    final namedParametersList =
        node.parameters.where((p) => p.isNamed).toList();

    if (namedParametersList.isEmpty) {
      return;
    }

    final parametersInfo = <ParameterType>[];

    for (final parameter in namedParametersList) {
      final parameterType = ParameterType.fromParameter(parameter);
      final previousParameterType = parametersInfo.lastOrNull;

      final isWrong = _isOrderingWrong(parameterType, previousParameterType);

      if (isWrong && previousParameterType != null) {
        _rule.reportAtNode(
          parameter,
          arguments: [
            parameterType.displayName,
            previousParameterType.displayName,
          ],
        );
      }

      parametersInfo.add(parameterType);
    }
  }

  bool _isOrderingWrong(
    ParameterType currentParameterType,
    ParameterType? previousParameterType,
  ) {
    return previousParameterType != null &&
        _parametersOrder.indexOf(previousParameterType) >
            _parametersOrder.indexOf(currentParameterType);
  }
}
