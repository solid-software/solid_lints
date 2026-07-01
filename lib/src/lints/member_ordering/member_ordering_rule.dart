import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/error/error.dart';
import 'package:solid_lints/src/lints/member_ordering/models/member_ordering_parameters.dart';
import 'package:solid_lints/src/lints/member_ordering/visitors/member_ordering_visitor.dart';
import 'package:solid_lints/src/models/solid_multi_lint_rule.dart';

/// A lint which allows to enforce a particular class member ordering
/// conventions.
///
/// ### Configuration format
///
/// The configuration uses a custom syntax for specifying members for ordering:
/// ```
/// annotation_modifiers_membertype
/// ```
/// Valid annotations: `overridden`, `protected`
///
/// Valid modifiers, in order of how they may appear in the final expression:
/// - `private` / `public`
/// - `static`
/// - `late`
/// - `var` / `final` / `const`
/// - `nullable`
/// - `named`
/// - `factory`
/// - `fields` / `getters` / `getters_setters` / `setters` / `constructors` /
///   `methods` / `method`.
///
///
/// Here are some examples of valid ordering group patterns:
///
/// - `public_static_const_fields`
/// - `private_late_fields`
/// - `private_nullable_fields`
/// - `public_methods`
/// - `overridden_methods`
///
/// It's also possible to specify ordering for custom-named class members:
/// - `my_custom_name_method`
/// - `dispose_method`
///
/// ### Example:
///
/// Assuming config:
///
/// ```yaml
/// plugins:
///   solid_lints:
///     diagnostics:
///       member_ordering:
///         alphabetize: true
///         order:
///           - fields
///           - getters_setters
///           - methods
/// ```
///
/// #### BAD:
///
/// ```dart
/// class Example {
///   int get getA => a; // LINT, getters-setters should be after fields
///
///   final b = 1;
///   final a = 1; // LINT, non-alphabetic order
///   final c = 1;
///
///   void method() {}
/// }
/// ```
///
/// #### GOOD:
///
/// ```dart
/// class Example {
///   final a = 1;
///   final b = 1;
///   final c = 1;
///
///   int get getA => a;
///
///   void method() {}
/// }
/// ```
class MemberOrderingRule extends SolidMultiLintRule<MemberOrderingParameters> {
  /// The name of this lint rule.
  static const lintName = 'member_ordering';

  /// Reported when a class member is declared out of order.
  static const wrongOrderCode = LintCode(
    lintName,
    '{0} should be before {1}.',
    uniqueName: 'wrong_order',
  );

  /// Reported when class members in the same group are not sorted
  /// alphabetically.
  static const alphabeticalOrderCode = LintCode(
    lintName,
    '{0} should be alphabetically before {1}.',
    uniqueName: 'alphabetical_order',
  );

  /// Reported when class members in the same group are not sorted
  /// alphabetically by type name.
  static const alphabeticalByTypeOrderCode = LintCode(
    lintName,
    '{0} type name should be alphabetically before {1}.',
    uniqueName: 'alphabetical_by_type_order',
  );

  /// Creates a new instance of [MemberOrderingRule].
  MemberOrderingRule({
    required super.analysisOptionsLoader,
  }) : super(
         name: lintName,
         description: 'Enforces a particular class member ordering convention.',
         parametersParser: MemberOrderingParameters.fromJson,
       );

  @override
  List<DiagnosticCode> get diagnosticCodes => [
    wrongOrderCode,
    alphabeticalOrderCode,
    alphabeticalByTypeOrderCode,
  ];

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    super.registerNodeProcessors(registry, context);

    final parameters =
        getParametersForContext(context) ?? MemberOrderingParameters.empty();
    final visitor = MemberOrderingVisitor(this, parameters);

    registry.addClassDeclaration(this, visitor);
  }
}
