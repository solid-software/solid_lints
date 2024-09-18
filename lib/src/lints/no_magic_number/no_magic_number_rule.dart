// MIT License
//
// Copyright (c) 2020-2021 Dart Code Checker team
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/listener.dart';
import 'package:collection/collection.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:solid_lints/src/lints/no_magic_number/models/no_magic_number_parameters.dart';
import 'package:solid_lints/src/lints/no_magic_number/visitors/no_magic_number_visitor.dart';
import 'package:solid_lints/src/models/rule_config.dart';
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
/// custom_lint:
///   rules:
///     - no_magic_number:
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
/// const circle = Circle(r: 10)
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
  /// The [LintCode] of this lint rule that represents
  /// the error when having magic number.
  static const String lintName = 'no_magic_number';

  NoMagicNumberRule._(super.config);

  /// Creates a new instance of [NoMagicNumberRule]
  /// based on the lint configuration.
  factory NoMagicNumberRule.createRule(CustomLintConfigs configs) {
    final config = RuleConfig<NoMagicNumberParameters>(
      configs: configs,
      name: lintName,
      paramsParser: NoMagicNumberParameters.fromJson,
      problemMessage: (_) => 'Avoid using magic numbers.'
          'Extract them to named constants or variables.',
    );

    return NoMagicNumberRule._(config);
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addCompilationUnit((node) {
      final visitor = NoMagicNumberVisitor();
      node.accept(visitor);

      final magicNumbers = visitor.literals
          .where(_isMagicNumber)
          .where(_isNotInsideVariable)
          .where(_isNotInsideCollectionLiteral)
          .where(_isNotInsideConstMap)
          .where(_isNotInsideConstConstructor)
          .where(_isNotInDateTime)
          .where(_isNotInsideIndexExpression)
          .where(_isNotInsideEnumConstantArguments)
          .where(_isNotDefaultValue)
          .where(_isNotInConstructorInitializer)
          .where(_isNotWidgetParameter);

      for (final magicNumber in magicNumbers) {
        reporter.atNode(magicNumber, code);
      }
    });
  }

  bool _isMagicNumber(Literal l) =>
      (l is DoubleLiteral &&
          !config.parameters.allowedNumbers.contains(l.value)) ||
      (l is IntegerLiteral &&
          !config.parameters.allowedNumbers.contains(l.value));

  bool _isNotInsideVariable(Literal l) {
    // Whether we encountered such node,
    // This is tracked because [InstanceCreationExpression] can be
    // inside [VariableDeclaration] removing unwanted literals

    bool isInstanceCreationExpression = false;
    return l.thisOrAncestorMatching((ancestor) {
          if (ancestor is InstanceCreationExpression) {
            isInstanceCreationExpression = true;
          }
          if (isInstanceCreationExpression) {
            return false;
          } else {
            return ancestor is VariableDeclaration;
          }
        }) ==
        null;
  }

  bool _isNotInDateTime(Literal l) =>
      l.thisOrAncestorMatching(
        (a) =>
            a is InstanceCreationExpression &&
            a.staticType?.getDisplayString() == 'DateTime',
      ) ==
      null;

  bool _isNotInsideEnumConstantArguments(Literal l) {
    final node = l.thisOrAncestorMatching(
      (ancestor) => ancestor is EnumConstantArguments,
    );

    return node == null;
  }

  bool _isNotInsideCollectionLiteral(Literal l) => l.parent is! TypedLiteral;

  bool _isNotInsideConstMap(Literal l) {
    final grandParent = l.parent?.parent;

    return !(grandParent is SetOrMapLiteral && grandParent.isConst);
  }

  bool _isNotInsideConstConstructor(Literal l) =>
      l.thisOrAncestorMatching((ancestor) {
        return ancestor is InstanceCreationExpression && ancestor.isConst;
      }) ==
      null;

  bool _isNotInsideIndexExpression(Literal l) => l.parent is! IndexExpression;

  bool _isNotDefaultValue(Literal literal) {
    return literal.thisOrAncestorOfType<DefaultFormalParameter>() == null;
  }

  bool _isNotInConstructorInitializer(Literal literal) {
    return literal.thisOrAncestorOfType<ConstructorInitializer>() == null;
  }

  bool _isNotWidgetParameter(Literal literal) {
    if (!config.parameters.allowedInWidgetParams) return true;

    final widgetCreationExpression = literal.thisOrAncestorMatching(
      _isWidgetCreationExpression,
    );

    return widgetCreationExpression == null;
  }

  bool _isWidgetCreationExpression(
    AstNode node,
  ) {
    if (node is! InstanceCreationExpression) return false;

    final staticType = node.staticType;

    if (staticType is! InterfaceType) return false;

    final widgetSupertype = staticType.allSupertypes.firstWhereOrNull(
      (supertype) => supertype.getDisplayString() == 'Widget',
    );

    return widgetSupertype != null;
  }
}
