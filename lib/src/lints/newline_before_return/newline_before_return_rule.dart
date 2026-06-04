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

import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/error/error.dart';
import 'package:solid_lints/src/lints/newline_before_return/visitors/newline_before_return_visitor.dart';

// Inspired by ESLint (https://eslint.org/docs/rules/newline-before-return)

/// Warns about missing newline before return in a code block
///
/// ### Example
///
/// #### BAD:
/// ```dart
/// int fn() {
///   final a = 0;
///   return 1; // LINT
/// }
///
/// void fn2() {
///   if (true) {
///     final a = 0;
///     return; // LINT
///   }
/// }
/// ```
///
/// #### GOOD:
/// ```dart
/// int fn0() {
///   return 1; // OK for single-line code blocks
/// }
///
/// Function getCallback() {
///   return () {
///     return 1; // OK
///   };
/// }
///
/// int fn() {
///   final a = 0;
///
///   return 1; // newline added -- OK
/// }
///
/// void fn2() {
///   if (true) {
///     return; // right under a conditional -- OK
///   }
/// }
/// ```
class NewlineBeforeReturnRule extends AnalysisRule {
  /// The name of the lint rule.
  static const String _lintName = 'newline_before_return';

  /// The message shown when the lint is triggered.
  static const String _lintMessage = 'Missing blank line before return.';

  /// Lint code for this rule.
  static const LintCode _code = LintCode(
    _lintName,
    _lintMessage,
  );

  /// Creates a new instance of [NewlineBeforeReturnRule].
  NewlineBeforeReturnRule()
    : super(
        name: _lintName,
        description: _lintMessage,
      );

  @override
  LintCode get diagnosticCode => _code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final visitor = NewLineBeforeReturnVisitor(this);
    registry.addReturnStatement(this, visitor);
  }

  // @override
  // void run(
  //   CustomLintResolver resolver,
  //   DiagnosticReporter reporter,
  //   CustomLintContext context,
  // ) {
  //   context.registry.addReturnStatement((node) {
  //     final visitor = NewLineBeforeReturnVisitor(resolver.lineInfo);
  //     visitor.visitReturnStatement(node);

  //     for (final element in visitor.statements) {
  //       reporter.atNode(element, code);
  //     }
  //   });
  // }
}
