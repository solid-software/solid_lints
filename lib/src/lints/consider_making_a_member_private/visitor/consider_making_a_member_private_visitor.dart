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

/// AST Visitor for identifying unused public members, global functions,
///  and variables.
class ConsiderMakingAMemberPrivateVisitor extends RecursiveAstVisitor<void> {
  final CompilationUnit _node;

  final _unusedPublicMembers = <ClassMember>{};
  final _unusedGlobalFunctions = <FunctionDeclaration>{};
  final _unusedGlobalVariables = <VariableDeclaration>{};

  /// Returns unused public members of classes.
  Iterable<ClassMember> get unusedPublicMembers => _unusedPublicMembers;

  /// Returns unused global functions.
  Iterable<FunctionDeclaration> get unusedGlobalFunctions =>
      _unusedGlobalFunctions;

  /// Returns unused global variables.
  Iterable<VariableDeclaration> get unusedGlobalVariables =>
      _unusedGlobalVariables;

  /// Constructor for [ConsiderMakingAMemberPrivateVisitor]
  ConsiderMakingAMemberPrivateVisitor(this._node);

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    // Check for unused public members in a class.
    final classMembers = node.members.where((member) {
      if (member is MethodDeclaration || member is FieldDeclaration) {
        final name = _getMemberName(member);
        return name != null && !_isPrivate(name);
      }
      if (member is ConstructorDeclaration) {
        final name = _getMemberName(member);
        if (name == null) return true;

        return !_isPrivate(name);
      }
      return false;
    }).toList();

    for (final member in classMembers) {
      final memberName = _getMemberName(member);
      if (!_isUsedOutsideClass(memberName, node)) {
        _unusedPublicMembers.add(member);
      }
    }

    super.visitClassDeclaration(node);
  }

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    final name = node.declaredElement?.name;
    if (!_isPrivate(name) && !_isUsedEntity(name)) {
      _unusedGlobalFunctions.add(node);
    }
    super.visitFunctionDeclaration(node);
  }

  @override
  void visitTopLevelVariableDeclaration(TopLevelVariableDeclaration node) {
    for (final variable in node.variables.variables) {
      final name = variable.declaredElement?.name;
      if (!_isPrivate(name) && !_isUsedEntity(name)) {
        _unusedGlobalVariables.add(variable);
      }
    }
    super.visitTopLevelVariableDeclaration(node);
  }

  bool _isPrivate(String? name) => name?.startsWith('_') ?? false;

  String? _getMemberName(ClassMember member) {
    if (member is MethodDeclaration) return member.declaredElement?.name;
    if (member is FieldDeclaration) {
      final fields = member.fields.variables;
      return fields.isNotEmpty ? fields.first.declaredElement?.name : null;
    }
    if (member is ConstructorDeclaration) {
      return member.declaredElement?.name;
    }
    return null;
  }

  bool _isUsedOutsideClass(String? memberName, ClassDeclaration classNode) {
    bool isUsedOutside = false;

    _node.visitChildren(
      _GlobalEntityUsageVisitor(
        entityName: memberName!,
        onUsageFound: () {
          isUsedOutside = true;
        },
      ),
    );

    if (memberName.isEmpty) return true;

    return isUsedOutside;
  }

  bool _isUsedEntity(String? entityName) {
    bool isUsed = false;

    if (entityName == null) return false;

    _node.visitChildren(
      _GlobalEntityUsageVisitor(
        entityName: entityName,
        onUsageFound: () {
          isUsed = true;
        },
      ),
    );

    return isUsed;
  }
}

class _GlobalEntityUsageVisitor extends RecursiveAstVisitor<void> {
  final String entityName;
  final Function() onUsageFound;

  _GlobalEntityUsageVisitor({
    required this.entityName,
    required this.onUsageFound,
  });

  @override
  void visitSimpleIdentifier(SimpleIdentifier identifier) {
    if (identifier.name == entityName) {
      onUsageFound();
    }
    super.visitSimpleIdentifier(identifier);
  }

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    if (node.constructorName.name?.name == entityName) {
      onUsageFound();
    }
    super.visitInstanceCreationExpression(node);
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.target != null && node.target.toString() == entityName) {
      onUsageFound();
    }
    super.visitMethodInvocation(node);
  }
}
