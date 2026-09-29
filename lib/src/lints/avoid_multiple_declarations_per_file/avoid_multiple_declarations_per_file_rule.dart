import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/error/error.dart';
import 'package:solid_lints/src/lints/avoid_multiple_declarations_per_file/models/avoid_multiple_declarations_per_file_parameters.dart';
import 'package:solid_lints/src/lints/avoid_multiple_declarations_per_file/visitors/avoid_multiple_declarations_per_file_visitor.dart';
import 'package:solid_lints/src/models/solid_lint_rule.dart';

/// Warns about multiple nominal declarations (classes, enums, mixins,
/// extensions, extension types) in a single file.
///
/// Each declaration should ideally live in its own dedicated file matching its
/// name, improving navigation, test structure, and Single Responsibility
/// Principle.
///
/// ### Example config:
///
/// ```yaml
/// solid_lints:
///   diagnostics:
///     avoid_multiple_declarations_per_file:
///       ignored_types:
///         - State
///       exclude_entity:
///         - extension_type
///         - enum
///       allow_private: true
///       maximum_loc: 20
/// ```
///
/// ### Example
///
/// #### BAD:
///
/// ```dart
/// class Parent extends StatelessWidget {}
///
/// class _Child extends StatelessWidget {} // LINT
/// ```
///
/// ```dart
/// class User {}
///
/// enum UserRole { admin, regular } // LINT
/// ```
///
/// #### GOOD:
///
/// ```dart
/// // parent.dart
/// import 'child.dart';
///
/// class Parent extends StatelessWidget {}
///
/// // child.dart
/// class Child extends StatelessWidget {}
/// ```
///
/// #### ALLOWED WITH CONFIGURATION (`ignored_types: [State]`):
///
/// ```dart
/// class SomeWidget extends StatefulWidget {}
///
/// class _SomeWidgetState extends State<SomeWidget> {}
/// ```
///
/// #### ALLOWED WITH CONFIGURATION (`maximum_loc: 10`):
///
/// ```dart
/// class MainClass {}
///
/// class SmallHelper {
///   // Comments and blank lines are excluded from LOC calculation.
///   void run() {}
/// }
/// ```
class AvoidMultipleDeclarationsPerFileRule
    extends SolidLintRule<AvoidMultipleDeclarationsPerFileParameters> {
  /// The lint rule name. Must be public to generate docs.
  static const lintName = 'avoid_multiple_declarations_per_file';

  static const _code = LintCode(
    lintName,
    "Avoid declaring multiple declarations in a single file. Extract '{0}' "
    'into its own file.',
  );

  @override
  DiagnosticCode get diagnosticCode => _code;

  /// Creates a new instance of [AvoidMultipleDeclarationsPerFileRule].
  AvoidMultipleDeclarationsPerFileRule({
    required super.analysisOptionsLoader,
  }) : super.withParameters(
         name: lintName,
         description:
             'Warns about declaring multiple declarations in a single file.',
         parametersParser: AvoidMultipleDeclarationsPerFileParameters.fromJson,
       );

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    super.registerNodeProcessors(registry, context);

    final parameters =
        getParametersForContext(context) ??
        AvoidMultipleDeclarationsPerFileParameters.empty();

    final visitor = AvoidMultipleDeclarationsPerFileVisitor(
      rule: this,
      parameters: parameters,
    );

    registry.addCompilationUnit(this, visitor);
  }
}
