import 'package:analyzer/diagnostic/diagnostic.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:solid_lints/src/lints/avoid_final_with_getter/visitors/avoid_final_with_getter_visitor.dart';
import 'package:solid_lints/src/models/rule_config.dart';
import 'package:solid_lints/src/models/solid_lint_rule.dart';

part 'fixes/avoid_final_with_getter_fix.dart';

/// Avoid using final private fields with getters.
///
/// Final private variables used in a pair with a getter
/// must be changed to a final public type without a getter
/// because it is the same as a public field.
///
/// ### Example
///
/// #### BAD:
///
/// ```dart
/// class MyClass {
///   final int _myField = 0;
///
///   int get myField => _myField;
/// }
/// ```
///
/// #### GOOD:
///
/// ```dart
/// class MyClass {
///   final int myField = 0;
/// }
/// ```
///
class AvoidFinalWithGetterRule extends SolidLintRule {
  /// This lint rule represents
  /// the error whether we use final private fields with getters.
  static const lintName = 'avoid_final_with_getter';

  final _diagnosticsInfoExpando = Expando<FinalWithGetterInfo>();

  AvoidFinalWithGetterRule._(super.config);

  /// Creates a new instance of [AvoidFinalWithGetterRule]
  /// based on the lint configuration.
  factory AvoidFinalWithGetterRule.createRule(CustomLintConfigs configs) {
    final rule = RuleConfig(
      configs: configs,
      name: lintName,
      problemMessage: (_) => 'Avoid final private fields with getters.',
    );

    return AvoidFinalWithGetterRule._(rule);
  }

  @override
  void run(
    CustomLintResolver resolver,
    DiagnosticReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addCompilationUnit((node) {
      final visitor = AvoidFinalWithGetterVisitor();
      node.accept(visitor);

      for (final element in visitor.getters) {
        final diagnostic = reporter.atNode(element.getter, code);

        _diagnosticsInfoExpando[diagnostic] = element;
      }
    });
  }

  @override
  List<Fix> getFixes() => [_FinalWithGetterFix(_diagnosticsInfoExpando)];
}
