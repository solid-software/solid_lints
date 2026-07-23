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

import 'package:analyzer/error/error.dart';
import 'package:solid_lints/src/lints/member_ordering/member_ordering_rule.dart';
import 'package:solid_lints/src/lints/member_ordering/models/member_info.dart';
import 'package:solid_lints/src/lints/member_ordering/models/member_order.dart';

/// Reporter for member ordering diagnostics.
class MemberOrderingReporter {
  final MemberOrderingRule _rule;
  final List<MemberInfo> _membersInfo;

  /// Creates instance of [MemberOrderingReporter].
  const MemberOrderingReporter({
    required List<MemberInfo> membersInfo,
    required MemberOrderingRule rule,
  }) : _membersInfo = membersInfo,
       _rule = rule;

  /// Generates diagnostic reports based on the configuration parameters.
  void report({
    required bool alphabetize,
    required bool alphabetizeByType,
  }) {
    _reportWrongOrder();
    if (alphabetize) {
      _reportAlphabeticalOrder();
    } else if (alphabetizeByType) {
      _reportAlphabeticalTypeOrder();
    }
  }

  void _reportWrongOrder() => _reportMembers(
    (order) => order.isWrong,
    MemberOrderingRule.wrongOrderCode,
    (order) => [
      order.memberGroup.toString(),
      order.previousMemberGroup?.toString() ?? '',
    ],
  );

  void _reportAlphabeticalOrder() => _reportMembers(
    (order) => order.isAlphabeticallyWrong,
    MemberOrderingRule.alphabeticalOrderCode,
    (order) => [
      order.memberNames.currentName,
      order.memberNames.previousName ?? '',
    ],
  );

  void _reportAlphabeticalTypeOrder() => _reportMembers(
    (order) => order.isByTypeWrong,
    MemberOrderingRule.alphabeticalByTypeOrderCode,
    (order) => [
      order.memberNames.currentTypeName,
      order.memberNames.previousTypeName ?? '',
    ],
  );

  void _reportMembers(
    bool Function(MemberOrder) filter,
    LintCode code,
    List<String> Function(MemberOrder) getArguments,
  ) {
    final filtered = _membersInfo.where((info) => filter(info.memberOrder));

    for (final memberInfo in filtered) {
      _rule.reportAtNode(
        memberInfo.classMember,
        diagnosticCode: code,
        arguments: getArguments(memberInfo.memberOrder),
      );
    }
  }
}
