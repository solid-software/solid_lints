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
import 'package:solid_lints/src/lints/member_ordering/member_ordering_rule.dart';
import 'package:solid_lints/src/lints/member_ordering/models/member_ordering_parameters.dart';
import 'package:solid_lints/src/lints/member_ordering/visitors/declaration_ordering_visitor.dart';
import 'package:solid_lints/src/lints/member_ordering/visitors/member_ordering_reporter.dart';
import 'package:solid_lints/src/utils/types_utils.dart';

/// AST Visitor which finds all class members and checks if they are
/// in order provided from rule config or default config
class MemberOrderingVisitor extends SimpleAstVisitor<void> {
  final MemberOrderingRule _rule;
  final MemberOrderingParameters _parameters;

  /// Creates instance of [MemberOrderingVisitor]
  MemberOrderingVisitor(this._rule, this._parameters);

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    super.visitClassDeclaration(node);

    final body = node.body;
    if (body is! BlockClassBody) return;

    final type = node.extendsClause?.superclass.type;
    final declarationVisitor = DeclarationOrderingVisitor(
      parameters: _parameters,
      isFlutterWidget:
          isWidgetOrSubclass(type) || isWidgetStateOrSubclass(type),
    );

    body.members.forEach(declarationVisitor.visit);

    MemberOrderingReporter(
      membersInfo: declarationVisitor.membersInfo,
      rule: _rule,
    ).report(
      alphabetize: _parameters.alphabetize,
      alphabetizeByType: _parameters.alphabetizeByType,
    );
  }
}
