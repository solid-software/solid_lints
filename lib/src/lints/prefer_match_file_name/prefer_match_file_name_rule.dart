import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:path/path.dart' as p;
import 'package:solid_lints/src/lints/prefer_match_file_name/visitors/prefer_match_file_name_visitor.dart';
import 'package:solid_lints/src/models/rule_config.dart';
import 'package:solid_lints/src/models/solid_lint_rule.dart';
import 'package:solid_lints/src/utils/node_utils.dart';

/// Warns about a mismatch between file name and first declared element inside.
///
/// This improves navigation by matching file content and file name.
///
/// ## Tests
///
/// State: **Disabled**.
///
/// It's acceptable to include stubs or other helper classes into the test file.
///
/// ### Example
///
/// #### BAD:
///
/// File name: my_class.dart
///
/// ```dart
/// class NotMyClass {} // LINT
/// ```
///
/// File name: other_class.dart
///
/// ```dart
/// class _OtherClass {}
/// class SomethingPublic {}  // LINT
/// ```
///
/// #### GOOD:
///
/// File name: my_class.dart
///
/// ```dart
/// class MyClass {} // OK
/// ```
///
/// File name: something_public.dart
///
/// ```dart
/// class _OtherClass {}
/// class SomethingPublic {}  // OK
/// ```
///
class PreferMatchFileNameRule extends SolidLintRule {
  /// The [LintCode] of this lint rule that represents the error if iterable
  /// access can be simplified.
  static const String lintName = 'prefer_match_file_name';
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

      final firstDeclaration = visitor.declarations.first;

      if (_doNormalizedNamesMatch(
        resolver.source.fullName,
        firstDeclaration.token.lexeme,
      )) return;

      final nodeType =
          humanReadableNodeType(firstDeclaration.parent).toLowerCase();

      reporter.reportErrorForToken(
        LintCode(
          name: lintName,
          problemMessage: 'File name does not match with first $nodeType name.',
        ),
        firstDeclaration.token,
      );
    });
  }

  bool _doNormalizedNamesMatch(String path, String identifierName) {
    final fileName = _normalizePath(path);
    final dartIdentifier = _normalizeDartIdentifierName(identifierName);

    return fileName == dartIdentifier;
  }

  String _normalizePath(String s) => p
      .basename(s)
      .split('.')
      .first
      .replaceAll(_onlySymbolsRegex, '')
      .toLowerCase();

  String _normalizeDartIdentifierName(String s) =>
      s.replaceAll(_onlySymbolsRegex, '').toLowerCase();
}
