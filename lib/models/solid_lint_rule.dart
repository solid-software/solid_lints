import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:solid_lints/models/metric_rule.dart';

/// A base class for emitting information about
/// issues with user's `.dart` files.
abstract class SolidLintRule<T extends Object?> extends DartLintRule {
  /// Constructor for [SolidLintRule] model.
  SolidLintRule(this.config) : super(code: config.lintCode);

  /// Configuration for a particular rule with all the
  /// defined custom parameters.
  final MetricRule<T> config;

  /// A flag which indicates whether this rule was enabled by the user.
  bool get enabled => config.enabled;
}
