import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/listener.dart';
import 'package:collection/collection.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:solid_lints/src/lints/avoid_initstate_field_initialization/visitors/avoid_initstate_field_initialization_visitor.dart';
import 'package:solid_lints/src/models/rule_config.dart';
import 'package:solid_lints/src/models/solid_lint_rule.dart';

/// An `avoid_initstate_field_initialization` rule which suggests using
/// declaration initializer over initializing field from `initState()`
/// if possible.
///
/// See more here: https://github.com/solid-software/solid_lints/issues/148
///
/// ### Example
///
/// #### BAD:
///
/// ```dart
/// class SomeState extends State<Some> {
///    late final X? x;
///    void initState() {
///       x = widget.x;
///     }
/// }
/// ```
///
/// #### GOOD:
///
/// ```dart
/// class SomeState extends State<Some> {
///   late final x = widget.x;
/// }
/// ```
///
class AvoidInitstateFieldInitializationRule extends SolidLintRule {
  /// This lint rule represents the error when field
  /// is initialized from `initState()`
  /// when declaration initializer is possible.
  static const lintName = 'avoid_initstate_field_initialization';

  /// Name of `initState()` method.
  static const initState = 'initState';

  AvoidInitstateFieldInitializationRule._(super.config);

  /// Creates a new instance of [AvoidInitstateFieldInitializationRule]
  /// based on the lint configuration.
  factory AvoidInitstateFieldInitializationRule.createRule(
    CustomLintConfigs configs,
  ) {
    final rule = RuleConfig(
      configs: configs,
      name: lintName,
      problemMessage: (_) => """
Avoid initialization final fields in initState().
Use declaration initializer instead.""",
    );

    return AvoidInitstateFieldInitializationRule._(rule);
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addClassDeclaration((classDec) {
      _checkClass(
        classDec: classDec,
        reporter: reporter,
        context: context,
      );
    });
    // context.registry.addMethodDeclaration(
    //   (method) {
    //     if (method.name.toString() != initState) return;

    //     _checkInitStateMethod(
    //       method: method,
    //       reporter: reporter,
    //       context: context,
    //     );
    //   },
    // );
  }

  void _checkClass({
    required ClassDeclaration classDec,
    required ErrorReporter reporter,
    required CustomLintContext context,
  }) {
    final classElement = classDec.declaredFragment?.element;
    if (classElement == null) return;

    //shortcut by checking class info without any visitor
    final initStateMethod = classElement.methods2.firstWhereOrNull(
      (method) => method.name3 == initState,
    );
    if (initStateMethod == null) return;

    //TODO REMOVE THIS
    //For test purposes ignoring all classes except in test file.
    if (!classElement.name3.toString().startsWith("_TestWidgetState")) return;
    print("\n${classElement.name3}");
    //TODO END REMOVE

    final visitor = AvoidInitstateFieldInitializationVisitor();

    classDec.accept(visitor);
  }

  void _checkInitStateMethod({
    required MethodDeclaration method,
    required ErrorReporter reporter,
    required CustomLintContext context,
  }) {
    final classDeclaration = method.thisOrAncestorOfType<ClassDeclaration>();
    final classElement = classDeclaration?.declaredFragment?.element;
    if (classElement == null) return;

    //TODO REMOVE THIS
    //For test purposes ignoring all classes except in test file.
    if (!classElement.name3.toString().startsWith("_TestWidgetState")) return;
    print("\n${classElement.name3}");
    //TODO END REMOVE

    //fields are clearly recognizeable here
    print(classElement.fields2);

    AstNode body = method.body;
    while (body.childEntities.firstOrNull != null) {
      if (body.childEntities.first is! AstNode) break;
      body = body.childEntities.first as AstNode;
    }

    for (final child in body.childEntities) {
      // print(child);
      // print(child.runtimeType);
      if (child is! ExpressionStatement) continue;

      final expr = child.expression;
      if (expr is! AssignmentExpression) continue;

      final leftHand = expr.leftHandSide;
      if (leftHand is! SimpleIdentifier) continue;
      print(leftHand.element);

      if (child.expression case final SimpleIdentifier id) {
        print(id.element);
      }
    }

    //TODO: if restoring this method, visitor should become Recursive again
    final visitor = AvoidInitstateFieldInitializationVisitor();
    method.visitChildren(visitor);
  }
}

//HACK: Failed attempt to use separate visitor, didn't help
class _VisitorWrapper extends SimpleAstVisitor<void> {
  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    if (node.name.toString() !=
        AvoidInitstateFieldInitializationRule.initState) {
      return;
    }
    final visitor = AvoidInitstateFieldInitializationVisitor();
    node.visitChildren(visitor);
  }
}
