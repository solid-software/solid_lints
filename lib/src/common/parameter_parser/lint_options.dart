import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:collection/collection.dart';

/// Option information for a specific [AnalysisRule].
class LintOptions {
  /// Creates a [LintOptions] from YAML.
  const LintOptions.fromYaml(Map<String, Object?> yaml, {required this.enabled})
      : json = yaml;

  /// Options with no [json]
  const LintOptions.empty({required this.enabled}) : json = const {};

  /// Whether the configuration enables/disables the lint rule.
  final bool enabled;

  /// Extra configurations for a [AnalysisRule].
  final Map<String, Object?> json;

  @override
  bool operator ==(Object other) =>
      other is LintOptions &&
      other.enabled == enabled &&
      const MapEquality<String, Object?>().equals(other.json, json);

  @override
  int get hashCode => Object.hash(
        enabled,
        const MapEquality<String, Object?>().hash(json),
      );
}
