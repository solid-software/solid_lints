import 'dart:collection';

import 'package:analyzer/file_system/file_system.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:path/path.dart' as p;
import 'package:solid_lints/src/common/parameter_parser/lint_options.dart';
import 'package:yaml/yaml.dart';

/// A global instance of [AnalysisOptionsLoader] for use across the plugin.
final analysisLoader = AnalysisOptionsLoader();

/// Loads and parses analysis options from a Dart project's YAML file.
class AnalysisOptionsLoader {
  /// Asynchronously loads analysis options from the specified [rootPath].
  Map<String, LintOptions> loadRules(String rootPath) {
    final file = PhysicalResourceProvider.INSTANCE.getFile(
      p.join(rootPath, 'analysis_options.yaml'),
    );

    final rules = _getRules(file);
    return rules;
  }

  Map<String, LintOptions> _getRules(File? analysisOptionsFile) {
    if (analysisOptionsFile == null || !analysisOptionsFile.exists) {
      return {};
    }

    final optionsString = analysisOptionsFile.readAsStringSync();
    Object? yaml;
    try {
      yaml = loadYaml(optionsString) as Object?;
    } catch (err) {
      return {};
    }
    if (yaml is! Map) return {};

    final rules = <String, LintOptions>{};
    final pluginsYaml = yaml['plugins'] as Object?;

    if (pluginsYaml is Map) {
      final solidLint = pluginsYaml['solid_lints'];
      if (solidLint is Map) {
        final diagnostics = solidLint['diagnostics'];

        if (diagnostics is Map) {
          for (final diag in diagnostics.entries) {
            final ruleName = diag.key as String;
            final value = diag.value;

            if (value is bool) {
              rules[ruleName] = LintOptions.empty(enabled: value);
            } else if (value is Map) {
              final map = Map<String, Object?>.from(value);

              final enabled = map.remove('enabled') as bool? ?? true;

              rules[ruleName] = LintOptions.fromYaml(
                map,
                enabled: enabled,
              );
            }
          }
        }
      }
    }

    return UnmodifiableMapView(rules);
  }
}
