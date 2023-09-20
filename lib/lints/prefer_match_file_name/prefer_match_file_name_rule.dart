import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:path/path.dart' as p;
import 'package:solid_lints/lints/prefer_match_file_name/prefer_match_file_name_visitor.dart';
import 'package:solid_lints/models/rule_config.dart';
import 'package:solid_lints/models/solid_lint_rule.dart';
import 'package:solid_lints/utils/node_utils.dart';

/// A `prefer-match-file-name` rule which warns about
/// mismatch between file name and declared element inside
class PreferMatchFileNameRule extends SolidLintRule {
  /// The [LintCode] of this lint rule that represents the error if iterable
  /// access can be simplified.
  static const String lintName = 'prefer-match-file-name';
  static final _onlySymbolsRegex = RegExp('[^a-zA-Z0-9]');

  PreferMatchFileNameRule._(super.config);

  /// Creates a new instance of [PreferMatchFileNameRule]
  /// based on the lint configuration.
  factory PreferMatchFileNameRule.createRule(CustomLintConfigs configs) {
    final config = RuleConfig(
      configs: configs,
      name: lintName,
      problemMessage: (value) =>
          'File name does not match with first declared element name.',
    );

    return PreferMatchFileNameRule._(config);
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addCompilationUnit((node) {
      final visitor = PreferMatchFileNameVisitor();

      node.accept(visitor);

      if (visitor.declarations.isEmpty) return;

      final info = visitor.declarations.first;
      if (!_hasMatchName(resolver.source.fullName, info.token.lexeme)) {
        final nodeType = humanReadableNodeType(info.parent).toLowerCase();

        reporter.reportErrorForToken(
          LintCode(
            name: lintName,
            problemMessage:
                'File name does not match with first $nodeType name.',
          ),
          info.token,
        );
      }
    });
  }

  bool _hasMatchName(String path, String identifierName) {
    final identifierNameFormatted =
        identifierName.replaceAll(_onlySymbolsRegex, '').toLowerCase();

    final fileNameFormatted = p
        .basename(path)
        .split('.')
        .first
        .replaceAll(_onlySymbolsRegex, '')
        .toLowerCase();

    return identifierNameFormatted == fileNameFormatted;
  }
}
