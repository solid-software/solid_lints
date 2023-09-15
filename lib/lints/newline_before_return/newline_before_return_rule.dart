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

import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:solid_lints/lints/newline_before_return/newline_before_return_visitor.dart';
import 'package:solid_lints/models/rule_config.dart';
import 'package:solid_lints/models/solid_lint_rule.dart';

// Inspired by ESLint (https://eslint.org/docs/rules/newline-before-return)

/// A `newline-before-return` rule which
/// warns about missing newline before return
class NewlineBeforeReturnRule extends SolidLintRule {
  /// The [LintCode] of this lint rule that represents the error if
  /// newline is missing before return statement
  static const String lintName = 'newline-before-return';

  NewlineBeforeReturnRule._(super.config);

  /// Creates a new instance of [NewlineBeforeReturnRule]
  /// based on the lint configuration.
  factory NewlineBeforeReturnRule.createRule(CustomLintConfigs configs) {
    final rule = RuleConfig(
      configs: configs,
      name: lintName,
      problemMessage: (value) => "Missing blank line before return.",
    );

    return NewlineBeforeReturnRule._(rule);
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addReturnStatement((node) {
      final visitor = NewLineBeforeReturnVisitor(resolver.lineInfo);
      visitor.visitReturnStatement(node);

      for (final element in visitor.statements) {
        reporter.reportErrorForNode(code, element);
      }
    });
  }
}
