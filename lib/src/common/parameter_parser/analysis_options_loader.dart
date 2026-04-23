import 'dart:collection';

import 'dart:io' as io;
import 'dart:io';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/file_system/file_system.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:solid_lints/src/common/parameter_parser/lint_options.dart';
import 'package:yaml/yaml.dart';

/// A global instance of [AnalysisOptionsLoader] for use across the plugin.
final analysisLoader = AnalysisOptionsLoader();

/// Loads and parses analysis options from a Dart project's YAML file.
class AnalysisOptionsLoader {
  Map<String, LintOptions> _rulesCache = {};

  /// Retrieves the currently loaded lint rules.
  Map<String, LintOptions> get rules => _rulesCache;

  /// Loads lint rules from the analysis options file based
  /// on the provided [RuleContext].
  void loadRulesFromContext(RuleContext context) {
    if (_rulesCache.isNotEmpty) {
      return;
    }

    final directory = context.allUnits.first.file.path;
    _loadRules(directory);
  }

  void _loadRules(String rootPath) {
    final yamlPath = _findNearestYamlUpwards(rootPath);

    if (yamlPath == null) {
      return;
    }

    final file = PhysicalResourceProvider.INSTANCE.getFile(yamlPath);

    final rules = _getRules(file);
    _rulesCache = rules;
  }

  String? _findNearestYamlUpwards(
    String filePath, {
    String fileName = 'analysis_options.yaml',
  }) {
    final startFile = io.File(filePath);
    io.Directory dir = startFile.parent;

    while (true) {
      final candidate = PhysicalResourceProvider.INSTANCE
          .getFile('${dir.path}${Platform.pathSeparator}$fileName');

      if (candidate.exists) {
        return candidate.path;
      }

      final parent = dir.parent;

      if (parent.path == dir.path) {
        return null;
      }

      dir = parent;
    }
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
