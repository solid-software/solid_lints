import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:solid_lints/src/lints/function_lines_of_code/models/function_lines_of_code_parameters.dart';
import 'package:solid_lints/src/lints/function_lines_of_code/visitors/function_lines_of_code_visitor.dart';
import 'package:solid_lints/src/models/rule_config.dart';
import 'package:solid_lints/src/models/solid_lint_rule.dart';

/// An approximate metric of meaningful lines of source code inside a function,
/// excluding blank lines and comments.
///
/// ### Example config:
///
/// ```yaml
/// custom_lint:
///   rules:
///     - function_lines_of_code:
///       max_lines: 100
///       excludeNames:
///         - "Build"
/// ```
class FunctionLinesOfCodeRule
    extends SolidLintRule<FunctionLinesOfCodeParameters> {
  /// This lint rule represents the error if number of
  /// parameters reaches the maximum value.
  static const lintName = 'function_lines_of_code';

  FunctionLinesOfCodeRule._(super.config);

  /// Creates a new instance of [FunctionLinesOfCodeRule]
  /// based on the lint configuration.
  factory FunctionLinesOfCodeRule.createRule(CustomLintConfigs configs) {
    final rule = RuleConfig(
      configs: configs,
      name: lintName,
      paramsParser: FunctionLinesOfCodeParameters.fromJson,
      problemMessage: (value) =>
          'The maximum allowed number of lines is ${value.maxLines}. '
          'Try splitting this function into smaller parts.',
    );

    return FunctionLinesOfCodeRule._(rule);
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    void checkNode(AstNode node) => _checkNode(resolver, reporter, node);

    void checkDeclarationNode(Declaration node) {
      final isIgnored = config.parameters.exclude.shouldIgnore(node);
      if (isIgnored) {
        return;
      }
      checkNode(node);
    }

    // Check for an anonymous function
    void checkFunctionExpressionNode(FunctionExpression node) {
      // If a FunctionExpression is an immediate child of a FunctionDeclaration
      // this means it's a named function, which are already check as part of
      // addFunctionDeclaration call.
      if (node.parent is FunctionDeclaration) {
        return;
      }
      checkNode(node);
    }

    context.registry.addFunctionDeclaration(checkDeclarationNode);
    context.registry.addMethodDeclaration(checkDeclarationNode);
    context.registry.addFunctionExpression(checkFunctionExpressionNode);
  }

  void _checkNode(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    AstNode node,
  ) {
    final visitor = FunctionLinesOfCodeVisitor(resolver.lineInfo);
    node.visitChildren(visitor);

    if (visitor.linesWithCode.length > config.parameters.maxLines) {
      if (node is! AnnotatedNode) {
        return reporter.atNode(node, code);
      }

      final startOffset = node.firstTokenAfterCommentAndMetadata.offset;
      final lengthDifference = startOffset - node.offset;

      reporter.atOffset(
        offset: startOffset,
        length: node.length - lengthDifference,
        errorCode: code,
      );
    }
  }
}
