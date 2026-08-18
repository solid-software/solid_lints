import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/error/error.dart';
import 'package:solid_lints/src/lints/no_magic_number/models/no_magic_number_parameters.dart';
import 'package:solid_lints/src/lints/no_magic_number/visitors/no_magic_number_rule_visitor.dart';
import 'package:solid_lints/src/models/solid_lint_rule.dart';

/// A `no_magic_number` rule which forbids having numbers without variable
///
/// There is a number of exceptions, where number literals are allowed:
/// - Collection literals;
/// - DateTime constructor usages;
/// - In constant constructors, including Enums;
/// - As a default value for parameters;
/// - In constructor initializer lists;
///
/// ### Example config:
///
/// ```yaml
/// solid_lints:
///   diagnostics:
///     no_magic_number:
///       allowed: [12, 42]
///       allowed_in_widget_params: true
/// ```
///
/// ### Example
///
/// #### BAD:
/// ```dart
/// double circumference(double radius) => 2 * 3.14 * radius; // LINT
///
/// bool canDrive(int age, {bool isUSA = false}) {
///   return isUSA ? age >= 16 : age > 18; // LINT
/// }
///
/// class Circle {
///   final int r;
///   const Circle({required this.r});
/// }
/// Circle(r: 5); // LINT
/// var circle = Circle(r: 10); // LINT
/// final circle2 = Circle(r: 10); // LINT
/// ```
///
/// #### GOOD:
/// ```dart
/// const pi = 3.14;
/// const radiusToDiameterCoefficient = 2;
/// double circumference(double radius) =>
///   radiusToDiameterCoefficient * pi * radius;
///
/// const usaDrivingAge = 16;
/// const worldWideDrivingAge = 18;
///
/// bool canDrive(int age, {bool isUSA = false}) {
///   return isUSA ? age >= usaDrivingAge : age > worldWideDrivingAge;
/// }
///
/// class Circle {
///   final int r;
///   const Circle({required this.r});
/// }
/// const Circle(r: 5);
/// const circle = Circle(r: 10);
/// ```
///
/// ### Allowed
/// ```dart
/// class ConstClass {
///   final int a;
///   const ConstClass(this.a);
///   const ConstClass.init() : a = 10;
/// }
///
/// enum ConstEnum {
///   // Allowed in enum arguments
///   one(1),
///   two(2);
///
///   final int value;
///   const ConstEnum(this.value);
/// }
///
/// // Allowed in const constructors
/// const classInstance = ConstClass(1);
///
/// // Allowed in list literals
/// final list = [1, 2, 3];
///
/// // Allowed in map literals
/// final map = {1: 'One', 2: 'Two'};
///
/// // Allowed in indexed expression
/// final result = list[1];
///
/// // Allowed in DateTime because it doesn't have const constructor
/// final apocalypse = DateTime(2012, 12, 21);
///
/// // Allowed for defaults in constructors and methods.
/// class DefaultValues {
///   final int value;
///   DefaultValues.named({this.value = 2});
///   DefaultValues.positional([this.value = 3]);
///
///   void methodWithNamedParam({int value = 4}) {}
///   void methodWithPositionalParam([int value = 5]) {}
/// }
/// ```
class NoMagicNumberRule extends SolidLintRule<NoMagicNumberParameters> {
  /// This lint rule represents
  /// the error when having magic number.
  static const String lintName = 'no_magic_number';

  static const _code = LintCode(
    lintName,
    'Avoid using magic numbers. Extract them to named constants or variables.',
  );

  @override
  DiagnosticCode get diagnosticCode => _code;

  /// Creates a new instance of [NoMagicNumberRule]
  NoMagicNumberRule({
    required super.analysisOptionsLoader,
  }) : super.withParameters(
         name: lintName,
         description: 'Forbids having numbers without variable.',
         parametersParser: NoMagicNumberParameters.fromJson,
       );

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    super.registerNodeProcessors(registry, context);

    final parameters =
        getParametersForContext(context) ?? NoMagicNumberParameters.empty();

    final visitor = NoMagicNumberRuleVisitor(this, parameters);

    registry.addDoubleLiteral(this, visitor);
    registry.addIntegerLiteral(this, visitor);
  }
}
