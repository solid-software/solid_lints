import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/file_system/file_system.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:solid_lints/src/common/parameter_parser/lint_options.dart';
import 'package:yaml/yaml.dart';

/// Loads and parses analysis options from a Dart project's YAML file.
class AnalysisOptionsLoader {
  final Map<String, Map<String, LintOptions>> _rulesCache = {};

  /// Gets the options for a specific rule by its name.
  LintOptions? getRuleOptions(RuleContext context, String ruleName) {
    final yamlPath = _findNearestFileUpwards(context.allUnits.first.file.path);
    if (yamlPath == null) return null;
    return _rulesCache[yamlPath]?[ruleName];
  }

  /// Loads lint rules from the analysis options file based
  /// on the provided [RuleContext].
  void loadRulesFromContext(RuleContext context) {
    if (context.allUnits.isEmpty) {
      return;
    }
    final filePath = context.allUnits.first.file.path;
    _loadRules(filePath);
  }

  void _loadRules(String rootPath) {
    final yamlPath = _findNearestFileUpwards(rootPath);

    if (yamlPath == null) {
      return;
    }

    if (_rulesCache.containsKey(yamlPath)) {
      return;
    }

    final file = PhysicalResourceProvider.INSTANCE.getFile(yamlPath);

    final rules = _getRules(file);
    _rulesCache[yamlPath] = rules;
  }

  String? _findNearestFileUpwards(
    String filePath, {
    String fileName = 'analysis_options.yaml',
  }) {
    final pathContext = PhysicalResourceProvider.INSTANCE.pathContext;
    var dir = pathContext.dirname(filePath);

    while (pathContext.dirname(dir) != dir) {
      final candidatePath = pathContext.join(dir, fileName);
      final candidate =
          PhysicalResourceProvider.INSTANCE.getFile(candidatePath);

      if (candidate.exists) {
        return candidatePath;
      }

      final parentDir = pathContext.dirname(dir);
      dir = parentDir;
    }
    return null;
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

    return rules;
  }
}
