import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/syntactic_entity.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:solid_lints/src/lints/avoid_using_api/avoid_using_api_rule.dart';
import 'package:solid_lints/src/lints/avoid_using_api/models/avoid_using_api_entry_parameters.dart';
import 'package:solid_lints/src/lints/avoid_using_api/models/avoid_using_api_parameters.dart';
import 'package:solid_lints/src/lints/avoid_using_api/utils/avoid_using_api_node_extensions.dart';
import 'package:solid_lints/src/utils/path_utils.dart';

/// The AST visitor that checks for avoided API usages.
class AvoidUsingApiVisitor extends SimpleAstVisitor<void> {
  /// The parameters configuration.
  final AvoidUsingApiParameters parameters;

  /// The rule context.
  final RuleContext context;

  List<AvoidUsingApiEntryParameters>? _cachedActiveEntries;

  /// Creates a new instance of [AvoidUsingApiVisitor].
  AvoidUsingApiVisitor({
    required this.parameters,
    required this.context,
  });

  List<AvoidUsingApiEntryParameters> _getActiveEntries(
    String filePath,
    String? rootPath,
  ) {
    return parameters.entries.where((entry) {
      return !shouldSkipFile(
        includeGlobs: entry.includes,
        excludeGlobs: entry.excludes,
        path: filePath,
        rootPath: rootPath,
      );
    }).toList();
  }

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) => _visit(
    node,
    super.visitSimpleIdentifier,
    (node, entry) => node.matches(entry) ? node : null,
  );

  @override
  void visitNamedType(NamedType node) => _visit(
    node,
    super.visitNamedType,
    (node, entry) => node.matches(entry) ? node : null,
  );

  @override
  void visitVariableDeclaration(VariableDeclaration node) => _visit(
    node,
    super.visitVariableDeclaration,
    (node, entry) => node.matches(entry) ? node.name : null,
  );

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) =>
      _visit(
        node,
        super.visitInstanceCreationExpression,
        (node, entry) => node.matches(entry) ? node.constructorName.type : null,
      );

  @override
  void visitMethodInvocation(MethodInvocation node) => _visit(
    node,
    super.visitMethodInvocation,
    (node, entry) => node.matches(entry) ? node.methodName : null,
  );

  void _visit<T>(
    T node,
    void Function(T) visitSuper,
    SyntacticEntity? Function(T, AvoidUsingApiEntryParameters) visitEntry,
  ) {
    visitSuper(node);

    final currentUnit = context.currentUnit;
    if (currentUnit == null) return;

    final activeEntries = _cachedActiveEntries ??= _getActiveEntries(
      currentUnit.file.path,
      context.package?.root.path,
    );

    final reporter = currentUnit.diagnosticReporter;

    for (final entry in activeEntries) {
      final severity =
          entry.severity ?? parameters.severity ?? DiagnosticSeverity.INFO;

      final code = LintCode(
        AvoidUsingApiRule.lintName,
        entry.reason ?? AvoidUsingApiRule.defaultMessage,
        severity: severity,
        uniqueName: AvoidUsingApiRule.getUniqueName(severity),
      );

      final target = visitEntry(node, entry);
      (() => switch (target) {
        AstNode() => reporter.atNode(target, code),
        Token() => reporter.atToken(target, code),
        _ => (),
      })();
    }
  }
}
