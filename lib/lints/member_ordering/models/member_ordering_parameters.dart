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

import 'package:solid_lints/lints/member_ordering/config_parser.dart';
import 'package:solid_lints/lints/member_ordering/models/member_group/member_group.dart';

/// A data model class that represents the member ordering input
/// parameters.
class MemberOrderingParameters {
  /// Config keys
  static const _orderConfig = 'order';
  static const _widgetsOrderConfig = 'widgets_order';
  static const _alphabetizeConfig = 'alphabetize';
  static const _alphabetizeByTypeConfig = 'alphabetize_by_type';

  /// Config used for members of regular class
  final List<MemberGroup> groupsOrder;

  /// Config used for members of Widget subclasses
  final List<MemberGroup> widgetsGroupsOrder;

  /// Boolean flag; indicates whether params should be in alphabetical order
  final bool alphabetize;

  /// Boolean flag; indicates whether params should be in alphabetical order by
  /// their static type
  final bool alphabetizeByType;

  /// Constructor for [MemberOrderingParameters] model
  const MemberOrderingParameters({
    required this.groupsOrder,
    required this.widgetsGroupsOrder,
    required this.alphabetize,
    required this.alphabetizeByType,
  });

  /// Method for creating from json data
  factory MemberOrderingParameters.fromJson(Map<String, Object?> json) =>
      MemberOrderingParameters(
        groupsOrder: MemberOrderingConfigParser.parseOrder(json[_orderConfig]),
        widgetsGroupsOrder: MemberOrderingConfigParser.parseWidgetsOrder(
          json[_widgetsOrderConfig],
        ),
        alphabetize: json[_alphabetizeConfig] as bool? ?? false,
        alphabetizeByType: json[_alphabetizeByTypeConfig] as bool? ?? false,
      );
}
