import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/file_system/file_system.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:solid_lints/src/common/parameter_parser/analysis_options_parser.dart';
import 'package:solid_lints/src/common/parameter_parser/cached_package_rules.dart';
import 'package:solid_lints/src/common/parameter_parser/package_config_resolver.dart';

/// Loads and parses analysis options from a Dart project's YAML file.
class AnalysisOptionsLoader {
  final ResourceProvider _resourceProvider;
  final Map<String, CachedPackageRules> _rulesCache = {};

  // Caches directory path -> nearest analysis_options.yaml file path
  final Map<String, String?> _nearestYamlCache = {};

  late final AnalysisOptionsParser _parser;

  /// Creates an instance of [AnalysisOptionsLoader].
  AnalysisOptionsLoader({
    ResourceProvider? resourceProvider,
    AnalysisOptionsParser? parser,
  }) : _resourceProvider =
            resourceProvider ?? PhysicalResourceProvider.INSTANCE {
    _parser = parser ??
        AnalysisOptionsParser(
          _resourceProvider,
          PackageConfigResolver(_resourceProvider),
        );
  }

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

  /// Checks if a rule is explicitly disabled.
  bool isRuleDisabled(RuleContext context, String ruleName) =>
      _withNearestAnalysisOptionsFilePathForContext<bool>(
        context,
        (path) {
          _loadRulesOptionsIfNewer(path);
          return _rulesCache[path]?.disabledRules.contains(ruleName) ?? false;
        },
      ) ??
      false;

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

    final rulesData = _parser.parse(analysisOptionsFile);
    _rulesCache[yamlPath] = CachedPackageRules(
      modificationStamp: modificationStamp,
      rules: rulesData.rules,
      disabledRules: rulesData.disabledRules,
    );
  }

  String? _findNearestAnalysisOptionsFilePath(String startDirectoryPath) {
    return _nearestYamlCache.putIfAbsent(startDirectoryPath, () {
      final pathContext = _resourceProvider.pathContext;
      var currentDirectoryPath = startDirectoryPath;

      while (currentDirectoryPath.isNotEmpty) {
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
    });
  }
}
