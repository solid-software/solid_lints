import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:solid_lints/src/lints/feature_envy/models/project_class_cache.dart';
import 'package:solid_lints/src/lints/feature_envy/utils/member_access_utils.dart';
import 'package:solid_lints/src/utils/node_utils.dart';
import 'package:solid_lints/src/utils/types_utils.dart';

/// A visitor that collects internal and external member accesses for a class.
class MemberAccessVisitor extends RecursiveAstVisitor<void> {
  final InterfaceElement _currentClass;
  final ProjectClassCache _projectClassCache;

  /// The number of accesses to members of the current class.
  int internalAccesses = 0;

  /// The counts of accesses to members of external classes.
  final externalAccessCounts = <InterfaceElement, int>{};

  /// Creates a new instance of [MemberAccessVisitor].
  MemberAccessVisitor(this._currentClass, this._projectClassCache);

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    super.visitSimpleIdentifier(node);

    if (node.element case final element?
        when element is! SetterElement && element.isInstanceMember) {
      if (MemberAccessUtils.isTargetOfExternalAccess(
        node,
        currentClass: _currentClass,
        projectClassCache: _projectClassCache,
      )) {
        return;
      }

      _processElement(
        element: element,
        target: node.memberAccessTarget,
      );
    }
  }

  @override
  void visitPatternField(PatternField node) {
    super.visitPatternField(node);

    if (node.element case final element? when element.isInstanceMember) {
      _processElement(
        element: element,
        target: node.parent?.matchedPatternExpression,
        isPatternField: true,
      );
    }
  }

  @override
  void visitBinaryExpression(BinaryExpression node) {
    super.visitBinaryExpression(node);

    if (node.element case final element?
        when element.isInstanceMethod && !node.isNullCheck) {
      _processElement(
        element: element,
        target: node.leftOperand,
      );
    }
  }

  @override
  void visitIndexExpression(IndexExpression node) {
    super.visitIndexExpression(node);

    if (node.element case final element? when element.isInstanceMethod) {
      _processElement(
        element: element,
        target: node.realTarget,
      );
    }
  }

  void _processOperatorAndWrite(
    Element? opElement,
    Element? writeElement,
    Expression operand,
  ) {
    if (opElement case final e? when e.isInstanceMethod) {
      _processElement(element: e, target: operand);
    }
    if (writeElement case final e? when e.isInstanceMember) {
      _processElement(element: e, target: operand.targetExpression);
    }
  }

  @override
  void visitPrefixExpression(PrefixExpression node) {
    super.visitPrefixExpression(node);
    _processOperatorAndWrite(node.element, node.writeElement, node.operand);
  }

  @override
  void visitPostfixExpression(PostfixExpression node) {
    super.visitPostfixExpression(node);
    _processOperatorAndWrite(node.element, node.writeElement, node.operand);
  }

  @override
  void visitAssignmentExpression(AssignmentExpression node) {
    super.visitAssignmentExpression(node);

    _processOperatorAndWrite(
      node.element,
      node.writeElement,
      node.leftHandSide,
    );
  }

  @override
  void visitFunctionExpressionInvocation(FunctionExpressionInvocation node) {
    super.visitFunctionExpressionInvocation(node);

    if (node.function.staticType case InterfaceType(:final element)) {
      if (element.getMethod('call') case final callMethod?
          when callMethod.isInstanceMethod) {
        _processElement(
          element: callMethod,
          target: node.function,
        );
      }
    }
  }

  @override
  void visitFunctionExpression(FunctionExpression node) {
    // Stop traversal to ignore accesses inside closures.
  }

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    // Stop traversal to ignore accesses inside nested functions.
  }

  void _processElement({
    required Element element,
    required Expression? target,
    bool isPatternField = false,
  }) {
    if (target == null && element.enclosingElement is ExtensionElement) {
      internalAccesses++;
      return;
    }

    final targetElement = MemberAccessUtils.resolveTargetElement(
      target,
      isPatternField: isPatternField,
    );

    final enclosingInterface = (targetElement ?? element).enclosingInterface;
    if (enclosingInterface == null) return;

    if (MemberAccessUtils.isInternalAccess(
      target,
      enclosingInterface,
      currentClass: _currentClass,
      isPatternField: isPatternField,
    )) {
      internalAccesses++;
      return;
    }

    if (enclosingInterface == _currentClass) return;

    if (_projectClassCache.isProjectClass(enclosingInterface) &&
        !enclosingInterface.isDataClass) {
      externalAccessCounts.update(
        enclosingInterface,
        (count) => count + 1,
        ifAbsent: () => 1,
      );
    }
  }
}
