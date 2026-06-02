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
    final packageRootPath = context.package?.root.path;
    if (packageRootPath == null) return null;

    final yamlPath = _findNearestAnalysisOptionsFilePath(packageRootPath);
    if (yamlPath == null) return null;

    return _rulesCache[yamlPath]?[ruleName];
  }

  /// Loads lint rules from the analysis options file based
  /// on the provided [RuleContext].
  void loadRulesFromContext(RuleContext context) {
    final packageRootPath = context.package?.root.path;
    if (packageRootPath == null) return;

    _loadRules(packageRootPath);
  }

  void _loadRules(String rootPath) {
    final yamlPath = _findNearestAnalysisOptionsFilePath(rootPath);

    if (yamlPath == null || _rulesCache.containsKey(yamlPath)) {
      return;
    }

    final analysisOptionsFile =
        PhysicalResourceProvider.INSTANCE.getFile(yamlPath);

    final rules = _getRules(analysisOptionsFile);
    _rulesCache[yamlPath] = rules;
  }

  String? _findNearestAnalysisOptionsFilePath(String packageRootPath) {
    final pathContext = PhysicalResourceProvider.INSTANCE.pathContext;
    String currentDirectoryPath = packageRootPath;

    while (pathContext.dirname(currentDirectoryPath) != currentDirectoryPath) {
      final candidatePath =
          pathContext.join(currentDirectoryPath, 'analysis_options.yaml');
      final candidateFile =
          PhysicalResourceProvider.INSTANCE.getFile(candidatePath);

      if (candidateFile.exists) {
        return candidatePath;
      }

      final parentDir = pathContext.dirname(currentDirectoryPath);
      currentDirectoryPath = parentDir;
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

    if (yaml
        case {'plugins': {'solid_lints': {'diagnostics': final diagnostics?}}}
        when diagnostics is Map) {
      for (final MapEntry(:key, :value) in diagnostics.entries) {
        if (key is! String) continue;

        final ruleName = key;

        if (value is bool) {
          rules[ruleName] = LintOptions.empty(enabled: value);
        } else if (value is Map) {
          rules[ruleName] = LintOptions.fromYaml(
            Map<String, Object?>.from(value),
            enabled: true,
          );
        }
      }
    }

    return rules;
  }
}
