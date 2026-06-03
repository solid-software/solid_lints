import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:solid_lints/src/lints/avoid_late_keyword/avoid_late_keyword_rule.dart';
import 'package:solid_lints/src/lints/avoid_late_keyword/models/avoid_late_keyword_parameters.dart';
import 'package:solid_lints/src/utils/types_utils.dart';

/// Visitor for [AvoidLateKeywordRule].
class AvoidLateKeywordVisitor extends SimpleAstVisitor<void> {
  final AvoidLateKeywordRule _rule;

  final AvoidLateKeywordParameters _parameters;

  /// Creates an instance of [AvoidLateKeywordVisitor].
  AvoidLateKeywordVisitor(this._rule, this._parameters);

  @override
  void visitVariableDeclaration(VariableDeclaration node) {
    if (!_shouldReport(node)) return;

    _rule.reportAtNode(node);
  }

  bool _shouldReport(VariableDeclaration node) {
    final isLateDeclaration = node.isLate;
    if (!isLateDeclaration) return false;

    final hasIgnoredType = _hasIgnoredType(node);
    if (hasIgnoredType) return false;

    final allowInitialized = _parameters.allowInitialized;
    if (!allowInitialized) return true;

    final hasInitializer = node.initializer != null;
    return !hasInitializer;
  }

  bool _hasIgnoredType(VariableDeclaration node) {
    final ignoredTypes = _parameters.ignoredTypes.toSet();
    if (ignoredTypes.isEmpty) return false;

    final variableType = node.declaredFragment?.element.type;
    if (variableType == null) return false;

    return variableType.hasIgnoredType(
      ignoredTypes: ignoredTypes,
    );
  }
}
