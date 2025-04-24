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

import 'package:analyzer/dart/ast/ast.dart' hide Annotation;
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:solid_lints/src/lints/named_parameters_ordering/models/parameter_type.dart';

/// AST Visitor which finds all methods, functions and constructor named
/// parameters and checks if they are in order provided from rule config
/// or default config
class NamedParametersOrderingVisitor
    extends RecursiveAstVisitor<List<ParameterInfo>> {
  final List<ParameterType> _parametersOrder;

  final List<ParameterInfo> _parametersInfo = <ParameterInfo>[];

  /// Creates instance of [NamedParametersOrderingVisitor]
  NamedParametersOrderingVisitor(this._parametersOrder);

  @override
  List<ParameterInfo> visitFormalParameterList(FormalParameterList node) {
    super.visitFormalParameterList(node);

    _parametersInfo.clear();

    final namedParametersList =
        node.parameters.where((p) => p.isNamed).toList();

    if (namedParametersList.isEmpty) {
      return _parametersInfo;
    }

    for (final parameter in namedParametersList) {
      _parametersInfo.add(
        ParameterInfo(
          formalParameter: parameter,
          parameterOrderingInfo: _getParameterOrderingInfo(parameter),
        ),
      );
    }

    return _parametersInfo;
  }

  ParameterOrderingInfo _getParameterOrderingInfo(FormalParameter parameter) {
    final parameterType = _getParameterType(parameter);
    final previousParameterType =
        _parametersInfo.lastOrNull?.parameterOrderingInfo.parameterType;

    return ParameterOrderingInfo(
      isWrong: _isOrderingWrong(parameterType, previousParameterType),
      parameterType: parameterType,
      previousParameterType: previousParameterType,
    );
  }

  ParameterType _getParameterType(
    FormalParameter parameter, [
    bool hasDefaultValue = false,
  ]) {
    if (parameter is DefaultFormalParameter &&
        parameter.parameter is! DefaultFormalParameter) {
      return _getParameterType(
        parameter.parameter,
        parameter.defaultValue != null,
      );
    }

    switch (parameter) {
      case SuperFormalParameter(:final isRequired):
        return isRequired ? ParameterType.requiredSuper : ParameterType.super$;

      case DefaultFormalParameter():
      case _ when hasDefaultValue:
        return ParameterType.default$;

      case FieldFormalParameter(:final isRequired) ||
            FunctionTypedFormalParameter(:final isRequired) ||
            SimpleFormalParameter(:final isRequired):
        return isRequired ? ParameterType.required : ParameterType.nullable;
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

/// Data class that holds AST function parameter and it's order info
class ParameterInfo {
  /// AST instance of an [FormalParameter]
  final FormalParameter formalParameter;

  /// Function parameter order info
  final ParameterOrderingInfo parameterOrderingInfo;

  /// Creates instance of an [ParameterInfo]
  const ParameterInfo({
    required this.formalParameter,
    required this.parameterOrderingInfo,
  });
}

/// Data class holds information about parameter order info
class ParameterOrderingInfo {
  /// Indicates if order is wrong
  final bool isWrong;

  /// Info about current parameter parameter type
  final ParameterType parameterType;

  /// Info about previous parameter parameter type
  final ParameterType? previousParameterType;

  /// Creates instance of [ParameterOrderingInfo]
  const ParameterOrderingInfo({
    required this.isWrong,
    required this.parameterType,
    required this.previousParameterType,
  });
}
