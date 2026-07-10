import 'package:analyzer/file_system/file_system.dart';
import 'package:solid_lints/src/common/constants.dart';
import 'package:solid_lints/src/common/parameter_parser/package_config_resolver.dart';
import 'package:solid_lints/src/common/parameter_parser/rules_data.dart';
import 'package:yaml/yaml.dart';

/// Parser for analysis_options.yaml files to extract RulesData.
class AnalysisOptionsParser {
  final ResourceProvider _resourceProvider;
  final PackageConfigResolver _packageConfigResolver;

  /// Creates a new instance of [AnalysisOptionsParser].
  AnalysisOptionsParser(this._resourceProvider, this._packageConfigResolver);

  /// Parses the given [analysisOptionsFile] and resolves its imports
  /// to return [RulesData].
  RulesData parse(File? analysisOptionsFile) {
    return _parseWithSeen(analysisOptionsFile, {});
  }

  RulesData _parseWithSeen(File? analysisOptionsFile, Set<String> seenPaths) {
    if (analysisOptionsFile == null || !analysisOptionsFile.exists) {
      return const RulesData.empty();
    }

    final path = analysisOptionsFile.path;
    if (seenPaths.contains(path)) {
      return const RulesData.empty();
    }
    seenPaths.add(path);

    final yaml = _parseYaml(analysisOptionsFile);
    if (yaml == null) {
      return const RulesData.empty();
    }

    final mergedRules = <String, Map<String, Object?>>{};
    final disabledRules = <String>{};

    _resolveAndMergeIncludes(
      analysisOptionsFile,
      yaml,
      seenPaths,
      mergedRules,
      disabledRules,
    );
    _parseRuleOptions(yaml, mergedRules, disabledRules);
    _parseSuppressedErrors(yaml, mergedRules, disabledRules);

    return RulesData(rules: mergedRules, disabledRules: disabledRules);
  }

  Map<dynamic, dynamic>? _parseYaml(File file) {
    try {
      final optionsString = file.readAsStringSync();
      final parsed = loadYaml(optionsString);
      return parsed is Map ? parsed : null;
    } catch (_) {
      return null;
    }
  }

  void _resolveAndMergeIncludes(
    File baseFile,
    Map<dynamic, dynamic> yaml,
    Set<String> seenPaths,
    Map<String, Map<String, Object?>> mergedRules,
    Set<String> disabledRules,
  ) {
    final includeOption = yaml['include'];
    if (includeOption is! String) return;

    final includedFile = _resolveIncludedFile(baseFile, includeOption);
    if (includedFile == null) return;

    final includedData = _parseWithSeen(includedFile, seenPaths);
    mergedRules.addAll(includedData.rules);
    disabledRules.addAll(includedData.disabledRules);
  }

  File? _resolveIncludedFile(File baseFile, String includePath) {
    final pathContext = _resourceProvider.pathContext;
    if (includePath.startsWith('package:')) {
      final resolvedPath = _packageConfigResolver.resolvePackageUri(
        baseFile.path,
        includePath,
      );
      if (resolvedPath != null) {
        return _resourceProvider.getFile(resolvedPath);
      }
      return null;
    }

    final baseDir = pathContext.dirname(baseFile.path);
    final resolvedPath = pathContext.join(baseDir, includePath);
    return _resourceProvider.getFile(resolvedPath);
  }

  void _parseRuleOptions(
    Map<dynamic, dynamic> yaml,
    Map<String, Map<String, Object?>> mergedRules,
    Set<String> disabledRules,
  ) {
    final rawDiagnostics = _extractDiagnostics(yaml);
    if (rawDiagnostics is! Map) return;

    for (final entry in rawDiagnostics.entries) {
      final key = entry.key;
      if (key is! String) continue;

      final ruleName = key;
      final value = entry.value;

      if (value is Map) {
        final existingOptions = mergedRules[ruleName] ?? {};
        mergedRules[ruleName] = <String, Object?>{
          ...existingOptions,
          for (final optionEntry in value.entries)
            if (optionEntry.key is String)
              optionEntry.key as String: optionEntry.value,
        };
        disabledRules.remove(ruleName);
      } else if (value is bool) {
        if (value) {
          disabledRules.remove(ruleName);
        } else {
          mergedRules.remove(ruleName);
          disabledRules.add(ruleName);
        }
      }
    }
  }

  Object? _extractDiagnostics(Map<dynamic, dynamic> yaml) {
    final pluginConfig = yaml[kPluginName];
    if (pluginConfig is Map) {
      return pluginConfig['diagnostics'];
    }

    final pluginsConfig = yaml['plugins'];
    if (pluginsConfig is Map) {
      final pluginSubConfig = pluginsConfig[kPluginName];
      if (pluginSubConfig is Map) {
        return pluginSubConfig['diagnostics'];
      }
    }

    return null;
  }

  /// Parses rule suppression configured under `analyzer: errors:`.
  ///
  /// By default, when a user excludes/ignores a rule using the IDE
  /// quick fix or standard settings, the Dart analysis server appends
  /// the following to `analysis_options.yaml`:
  ///
  /// ```yaml
  /// analyzer:
  ///   errors:
  ///     solid_lints/rule_name: ignore
  /// ```
  ///
  /// To respect this standard mechanism and prevent the plugin rules
  /// from running, we parse this section and add suppressed rules
  /// to [disabledRules].
  void _parseSuppressedErrors(
    Map<dynamic, dynamic> yaml,
    Map<String, Map<String, Object?>> mergedRules,
    Set<String> disabledRules,
  ) {
    final analyzer = yaml['analyzer'];
    if (analyzer is! Map) return;

    final errors = analyzer['errors'];
    if (errors is! Map) return;

    const pluginPrefix = '$kPluginName/';

    for (final entry in errors.entries) {
      final key = entry.key;
      if (key is! String) continue;

      final errorValue = entry.value;
      final ruleName = key.startsWith(pluginPrefix)
          ? key.substring(pluginPrefix.length)
          : key;

      if (errorValue == 'ignore') {
        mergedRules.remove(ruleName);
        disabledRules.add(ruleName);
      } else {
        disabledRules.remove(ruleName);
      }
    }
  }
}
