import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/error/error.dart';
import 'package:solid_lints/src/lints/use_nearest_context/fixes/rename_nearest_context_parameter_fix.dart';
import 'package:solid_lints/src/lints/use_nearest_context/fixes/replace_with_nearest_context_parameter_fix.dart';
import 'package:solid_lints/src/lints/use_nearest_context/visitors/use_nearest_context_visitor.dart';
import 'package:solid_lints/src/models/rule_with_fixes.dart';

/// A rule which checks that we use BuildContext from the nearest available
/// scope.
///
/// ### Example:
/// #### BAD:
/// ```dart
/// class SomeWidget extends StatefulWidget {
/// ...
/// }
///
/// class _SomeWidgetState extends State<SomeWidget> {
///   ...
///   void _showDialog() {
///     showModalBottomSheet(
///       context: context,
///       builder: (BuildContext _) {
///         final someProvider = context.watch<SomeProvider>(); // LINT, BuildContext is used not from the nearest available scope
///
///         return const SizedBox.shrink();
///       },
///     );
///   }
/// }
/// ```
/// #### GOOD:
/// ```dart
/// class SomeWidget extends StatefulWidget {
/// ...
/// }
///
/// class _SomeWidgetState extends State<SomeWidget> {
///   ...
///   void _showDialog() {
///     showModalBottomSheet(
///       context: context,
///       builder: (BuildContext context)
///         final someProvider = context.watch<SomeProvider>(); // OK
///
///         return const SizedBox.shrink();
///       },
///     );
///   }
/// }
/// ```
///
class UseNearestContextRule extends AnalysisRule implements RuleWithFixes {
  /// This lint rule represents the error if BuildContext is used not from the
  /// nearest available scope
  static const lintName = 'use_nearest_context';

  /// The code to report for a violation
  static const LintCode code = LintCode(
    lintName,
    'Use the nearest BuildContext parameter instead of the outer one.',
  );

  /// Creates a new instance of [UseNearestContextRule].
  UseNearestContextRule()
    : super(
        name: lintName,
        description: code.problemMessage,
      );

  @override
  LintCode get diagnosticCode => code;

  @override
  Iterable<MapEntry<DiagnosticCode, ProducerGenerator>> get fixesForCodes =>
      const [
        MapEntry(code, RenameNearestContextParameterFix.new),
        MapEntry(code, ReplaceWithNearestContextParameterFix.new),
      ];

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final visitor = UseNearestContextVisitor(this);
    registry.addSimpleIdentifier(this, visitor);
    registry.addThisExpression(this, visitor);
  }
}
