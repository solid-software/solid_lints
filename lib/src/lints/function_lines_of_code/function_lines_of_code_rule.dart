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
  /// The [LintCode] of this lint rule that represents the error if number of
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

    context.registry.addMethodDeclaration(checkNode);
    context.registry.addFunctionDeclaration(checkNode);
    context.registry.addFunctionExpression(checkNode);
  }

  void _checkNode(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    AstNode node,
  ) {
    final functionName = _getFunctionName(node);
    if (functionName != null &&
        config.parameters.excludeNames.contains(functionName)) {
      return;
    }

    final visitor = FunctionLinesOfCodeVisitor(resolver.lineInfo);
    node.visitChildren(visitor);

    if (visitor.linesWithCode.length > config.parameters.maxLines) {
      if (node is! AnnotatedNode) {
        return reporter.reportErrorForNode(code, node);
      }

      final startOffset = node.firstTokenAfterCommentAndMetadata.offset;
      final lengthDifference = startOffset - node.offset;

      reporter.reportErrorForOffset(
        code,
        startOffset,
        node.length - lengthDifference,
      );
    }
  }

  String? _getFunctionName(AstNode node) {
    if (node is FunctionDeclaration) {
      return node.name.lexeme;
    } else if (node is MethodDeclaration) {
      return node.name.lexeme;
    } else if (node is FunctionExpression) {
      return node.declaredElement?.name;
    } else {
      return null;
    }
  }
}
