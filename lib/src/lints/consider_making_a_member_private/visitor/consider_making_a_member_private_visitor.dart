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

/// The AST visitor that will find lines with code.
class ConsiderMakingAMemberPrivateVisitor extends RecursiveAstVisitor<void> {
  final CompilationUnit _node;

  final _unusedPublicMembers = <ClassMember>{};

  /// Returns public members that are not used as representatives of the class.
  Iterable<ClassMember> get unusedPublicMembers => _unusedPublicMembers;

  /// Creates a new instance of [ConsiderMakingAMemberPrivateVisitor].
  ConsiderMakingAMemberPrivateVisitor(this._node);

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    final classMembers = node.members.where((member) {
      if (member is MethodDeclaration || member is FieldDeclaration) {
        final name = _getMemberName(member);
        return name != null && !_isPrivate(name);
      }
      return false;
    }).toList();

    for (final member in classMembers) {
      final memberName = _getMemberName(member)!;
      if (!_isUsedOutsideClass(memberName, node)) {
        _unusedPublicMembers.add(member);
      }
    }

    super.visitClassDeclaration(node);
  }

  bool _isPrivate(String name) => name.startsWith('_');

  String? _getMemberName(ClassMember member) {
    if (member is MethodDeclaration) return member.declaredElement?.name;
    if (member is FieldDeclaration) {
      final fields = member.fields.variables;
      return fields.isNotEmpty ? fields.first.declaredElement?.name : null;
    }
    return null;
  }

  bool _isUsedOutsideClass(String memberName, ClassDeclaration classNode) {
    bool isUsedOutside = false;

    _node.visitChildren(
      _PublicMemberUsageVisitor(
        memberName: memberName,
        classNode: classNode,
        onUsageFound: () {
          isUsedOutside = true;
        },
      ),
    );

    return isUsedOutside;
  }
}

class _PublicMemberUsageVisitor extends RecursiveAstVisitor<void> {
  final String memberName;
  final ClassDeclaration classNode;
  final Function() onUsageFound;

  _PublicMemberUsageVisitor({
    required this.memberName,
    required this.classNode,
    required this.onUsageFound,
  });

  @override
  void visitSimpleIdentifier(SimpleIdentifier identifier) {
    if (identifier.name == memberName) {
      final parentClass = identifier.thisOrAncestorOfType<ClassDeclaration>();
      if (parentClass != classNode) {
        onUsageFound();
      }
    }

    super.visitSimpleIdentifier(identifier);
  }
}
