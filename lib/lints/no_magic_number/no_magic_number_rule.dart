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
import 'package:solid_lints/lints/no_magic_number/models/no_magic_number_parameters.dart';
import 'package:solid_lints/lints/no_magic_number/no_magic_number_visitor.dart';
import 'package:solid_lints/models/rule_config.dart';
import 'package:solid_lints/models/solid_lint_rule.dart';

/// A `no_magic_number` rule which forbids having numbers without variable
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
        reporter.reportErrorForNode(code, magicNumber);
      }
    });
  }

  bool _isMagicNumber(Literal l) =>
      (l is DoubleLiteral &&
          !config.parameters.allowedNumbers.contains(l.value)) ||
      (l is IntegerLiteral &&
          !config.parameters.allowedNumbers.contains(l.value));

  bool _isNotInsideVariable(Literal l) =>
      l.thisOrAncestorMatching(
        (ancestor) => ancestor is VariableDeclaration,
      ) ==
      null;

  bool _isNotInDateTime(Literal l) =>
      l.thisOrAncestorMatching(
        (a) =>
            a is InstanceCreationExpression &&
            a.staticType?.getDisplayString(withNullability: false) ==
                'DateTime',
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
      l.thisOrAncestorMatching(
        (ancestor) =>
            ancestor is InstanceCreationExpression && ancestor.isConst,
      ) ==
      null;

  bool _isNotInsideIndexExpression(Literal l) => l.parent is! IndexExpression;

  bool _isNotDefaultValue(Literal literal) {
    return literal.thisOrAncestorOfType<DefaultFormalParameter>() == null;
  }

  bool _isNotInConstructorInitializer(Literal literal) {
    return literal.thisOrAncestorOfType<ConstructorInitializer>() == null;
  }

  bool _isNotWidgetParameter(Literal literal) {
    final instanceCreationExpression =
        literal.thisOrAncestorOfType<InstanceCreationExpression>();

    if (instanceCreationExpression == null) return true;

    final staticType = instanceCreationExpression.staticType;

    if (staticType is! InterfaceType) return true;

    final widgetSupertype = staticType.allSupertypes.firstWhereOrNull(
      (supertype) =>
          supertype.getDisplayString(withNullability: false) == 'Widget',
    );

    return widgetSupertype == null;
  }
}
