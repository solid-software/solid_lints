import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:solid_lints/src/lints/avoid_late_keyword/visitors/avoid_late_keyword_visitor.dart';

/// Avoid `late` keyword
///
/// Using `late` disables compile time safety for what would else be a nullable
/// variable. Instead, a runtime check is made, which may throw an unexpected
/// exception for an uninitialized variable.
///
/// ### Example config:
///
/// ```yaml
/// custom_lint:
///    rules:
///      - avoid_late_keyword:
///        allow_initialized: false
///        ignored_types:
///         - AnimationController
///         - ColorTween
/// ```
///
/// ### Example
///
/// #### BAD:
/// ```dart
/// class AvoidLateKeyword {
///   late final int field; // LINT
///
///   void test() {
///     late final local = ''; // LINT
///   }
/// }
/// ```
///
/// #### GOOD:
/// ```dart
/// class AvoidLateKeyword {
///   final int? field; // LINT
///
///   void test() {
///     final local = ''; // LINT
///   }
/// }
/// ```
class AvoidLateKeywordRule extends AnalysisRule {
  static const String _lintName = 'avoid_late_keyword';

  static const LintCode _code = LintCode(
    _lintName,
    'Avoid using the "late" keyword. It may result in runtime exceptions.',
  );

  /// Creates an instance of [AvoidLateKeywordRule].
  AvoidLateKeywordRule()
      : super(
          name: _lintName,
          description: 'Warns against using the late keyword.',
        );

  @override
  LintCode get diagnosticCode => _code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addVariableDeclaration(this, AvoidLateKeywordVisitor(this));
  }
}
