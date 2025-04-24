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

import 'package:solid_lints/src/lints/named_parameters_ordering/config_parser.dart';
import 'package:solid_lints/src/lints/named_parameters_ordering/models/parameter_type.dart';

/// A data model class that represents the parameter ordering input
/// parameters.
class NamedParametersOrderingParameters {
  /// Config keys
  static const _orderConfig = 'order';

  /// Config used for order of named parameters
  final List<ParameterType> order;

  /// Constructor for [NamedParametersOrderingParameters] model
  const NamedParametersOrderingParameters({required this.order});

  /// Method for creating from json data
  factory NamedParametersOrderingParameters.fromJson(
    Map<String, Object?> json,
  ) =>
      NamedParametersOrderingParameters(
        order: NamedParametersConfigParser.parseOrder(
          json[_orderConfig],
        ),
      );
}
