import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/file_system/file_system.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:solid_lints/src/common/parameter_parser/cached_package_rules.dart';
import 'package:yaml/yaml.dart';

/// Loads and parses analysis options from a Dart project's YAML file.
class AnalysisOptionsLoader {
  final ResourceProvider _resourceProvider;
  final Map<String, CachedPackageRules> _rulesCache = {};

  /// Creates an instance of [AnalysisOptionsLoader]
  AnalysisOptionsLoader({ResourceProvider? resourceProvider})
    : _resourceProvider = resourceProvider ?? PhysicalResourceProvider.INSTANCE;

  /// Gets the options for a specific rule by its name.
  Map<String, Object?>? getRuleOptions(RuleContext context, String ruleName) =>
      _withNearestAnalysisOptionsFilePathForContext<Map<String, Object?>?>(
        context,
        (path) => _rulesCache[path]?.rules[ruleName],
      );

  /// Gets the options for a specific rule by looking up the nearest
  /// `analysis_options.yaml` from the given [filePath]'s directory.
  ///
  /// Unlike [getRuleOptions], this method does not require a [RuleContext]
  /// and can be used from quick fixes.
  Map<String, Object?>? getRuleOptionsForFile(
    String filePath,
    String ruleName,
  ) {
    final dirPath = _resourceProvider.pathContext.dirname(filePath);
    final yamlPath = _findNearestAnalysisOptionsFilePath(dirPath);
    if (yamlPath == null) return null;
    _loadRulesOptionsIfNewer(yamlPath);
    return _rulesCache[yamlPath]?.rules[ruleName];
  }

  /// Loads lint rules from the analysis options file for all rules
  /// using the provided [RuleContext].
  void loadRulesOptionsFromContext(RuleContext context) =>
      _withNearestAnalysisOptionsFilePathForContext(
        context,
        _loadRulesOptionsIfNewer,
      );

  T? _withNearestAnalysisOptionsFilePathForContext<T>(
    RuleContext context,
    T Function(String) f,
  ) {
    final filePath = context.definingUnit.file.path;
    final dirPath = _resourceProvider.pathContext.dirname(filePath);
    final yamlPath = _findNearestAnalysisOptionsFilePath(dirPath);

    if (yamlPath == null) return null;

    return f(yamlPath);
  }

  void _loadRulesOptionsIfNewer(String yamlPath) {
    final analysisOptionsFile = _resourceProvider.getFile(yamlPath);
    final modificationStamp = analysisOptionsFile.modificationStamp;
    final cachedRules = _rulesCache[yamlPath];

    if (cachedRules?.modificationStamp == modificationStamp) {
      return;
    }

    final rules = _getRules(analysisOptionsFile);
    _rulesCache[yamlPath] = CachedPackageRules(
      modificationStamp: modificationStamp,
      rules: rules,
    );
  }

  String? _findNearestAnalysisOptionsFilePath(String startDirectoryPath) {
    final pathContext = _resourceProvider.pathContext;
    String currentDirectoryPath = startDirectoryPath;

    while (true) {
      final candidatePath = pathContext.join(
        currentDirectoryPath,
        'analysis_options.yaml',
      );
      final candidateFile = _resourceProvider.getFile(candidatePath);

      if (candidateFile.exists) {
        return candidatePath;
      }

      final parentDir = pathContext.dirname(currentDirectoryPath);
      if (parentDir == currentDirectoryPath) {
        break;
      }
      currentDirectoryPath = parentDir;
    }

    return null;
  }

  Map<String, Map<String, Object?>> _getRules(File? analysisOptionsFile) {
    if (analysisOptionsFile == null || !analysisOptionsFile.exists) {
      return {};
    }

    final optionsString = analysisOptionsFile.readAsStringSync();
    Object? yaml;
    try {
      yaml = loadYaml(optionsString);
    } catch (_) {
      return {};
    }

    Object? rawDiagnostics;
    if (yaml case {'solid_lints': {'diagnostics': final diagnostics}}) {
      rawDiagnostics = diagnostics;
    } else if (yaml case {
      'plugins': {'solid_lints': {'diagnostics': final diagnostics}},
    }) {
      rawDiagnostics = diagnostics;
    }

    if (rawDiagnostics is! Map) return {};

    return {
      for (final entry in rawDiagnostics.entries)
        if (entry.key is String && entry.value is Map)
          entry.key as String: <String, Object?>{
            for (final optionEntry in (entry.value as Map).entries)
              if (optionEntry.key is String)
                optionEntry.key as String: optionEntry.value,
          },
    };
  }
}
