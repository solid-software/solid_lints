import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/error/error.dart';
import 'package:path/path.dart' as p;
import 'package:solid_lints/src/lints/prefer_match_file_name/models/prefer_match_file_name_parameters.dart';
import 'package:solid_lints/src/lints/prefer_match_file_name/visitors/prefer_match_file_name_visitor.dart';
import 'package:solid_lints/src/models/solid_lint_rule.dart';

/// Warns about a mismatch between file name and first declared element inside.
///
/// This improves navigation by matching file content and file name.
///
/// ### Example config:
///
/// ```yaml
/// plugins:
///   solid_lints:
///     diagnostics:
///       prefer_match_file_name:
///         exclude_entity:
///           - mixin
///           - extension
///           - extension_type
///           - enum
/// ```
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
class PreferMatchFileNameRule
    extends SolidLintRule<PreferMatchFileNameParameters> {
  /// Name of the lint.
  static const lintName = 'prefer_match_file_name';
  static final _onlySymbolsRegex = RegExp('[^a-zA-Z0-9]');

  static const _code = LintCode(
    lintName,
    'File name does not match with first {0} name.',
  );

  @override
  DiagnosticCode get diagnosticCode => _code;

  /// Creates a new instance of [PreferMatchFileNameRule]
  /// based on the lint configuration.
  PreferMatchFileNameRule({
    required super.analysisOptionsLoader,
  }) : super.withParameters(
         name: lintName,
         description:
             'Warns about a mismatch between file name and first declared '
             'element inside.',
         parametersParser: PreferMatchFileNameParameters.fromJson,
       );

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    super.registerNodeProcessors(registry, context);

    final parameters =
        getParametersForContext(context) ??
        PreferMatchFileNameParameters.empty();

    final visitor = PreferMatchFileNameVisitor(
      this,
      context,
      parameters.excludeEntity,
    );

    registry.addCompilationUnit(this, visitor);
  }

  /// Checks if the normalized file path matches the normalized identifier name.
  bool doNormalizedNamesMatch(String path, String identifierName) {
    final fileName = _normalizePath(path);
    final dartIdentifier = _normalizeDartIdentifierName(identifierName);

    return fileName == dartIdentifier;
  }

  String _normalizePath(String s) =>
      _normalizeDartIdentifierName(p.basename(s).split('.').first);

  String _normalizeDartIdentifierName(String s) =>
      s.replaceAll(_onlySymbolsRegex, '').toLowerCase();
}
