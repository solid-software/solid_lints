import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:solid_lints/src/lints/feature_envy/feature_envy_rule.dart';
import 'package:solid_lints/src/lints/feature_envy/models/feature_envy_metrics.dart';
import 'package:solid_lints/src/lints/feature_envy/models/feature_envy_parameters.dart';
import 'package:solid_lints/src/lints/feature_envy/models/project_class_cache.dart';
import 'package:solid_lints/src/lints/feature_envy/visitors/member_access_visitor.dart';
import 'package:solid_lints/src/utils/types_utils.dart';

/// The AST visitor that checks every method for feature envy.
class FeatureEnvyVisitor extends SimpleAstVisitor<void> {
  final FeatureEnvyRule _rule;
  final FeatureEnvyParameters _parameters;
  final _projectClassCache = ProjectClassCache();

  /// Creates a new instance of [FeatureEnvyVisitor].
  FeatureEnvyVisitor(this._rule, this._parameters);

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    if (node.isStatic) return; // ignore static methods
    if (node.body case EmptyFunctionBody()) return;
    if (_parameters.exclude.shouldIgnore(node)) return;

    final interfaceElement = node.declaredFragment?.element.enclosingElement;
    if (interfaceElement is! InterfaceElement) return;

    final classType = interfaceElement.thisType;
    if (isWidgetOrSubclass(classType) || isWidgetStateOrSubclass(classType)) {
      return;
    }

    final accessVisitor = MemberAccessVisitor(
      interfaceElement,
      _projectClassCache,
    );
    node.accept(accessVisitor);

    if (accessVisitor.externalAccessCounts.isEmpty) return;

    final metrics = FeatureEnvyMetrics.calculate(
      internalAccesses: accessVisitor.internalAccesses,
      externalAccessCounts: accessVisitor.externalAccessCounts,
    );

    if (metrics.exceedsThresholds(_parameters)) {
      _rule.reportAtToken(
        node.name,
        arguments: [
          metrics.maxEnvyElement?.name ?? '',
          interfaceElement.name ?? '',
        ],
      );
    }
  }
}
