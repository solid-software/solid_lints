import 'package:analyzer/file_system/file_system.dart';
import 'package:solid_lints/src/common/parameter_parser/package_config_resolver.dart';
import 'package:solid_lints/src/common/parameter_parser/rules_data.dart';
import 'package:solid_lints/src/common/solid_lints_constants.dart';
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

    final yaml = _parseYaml(analysisOptionsFile);
    if (yaml == null) {
      return const RulesData.empty();
    }

    final mergedRules = <String, Map<String, Object?>>{};
    final disabledRules = <String>{};

    final nextSeenPaths = {...seenPaths, path};
    _resolveAndMergeIncludes(
      analysisOptionsFile,
      yaml,
      nextSeenPaths,
      mergedRules,
      disabledRules,
    );
    _parseRuleOptions(yaml, mergedRules, disabledRules);
    _parseSuppressedErrors(yaml, mergedRules, disabledRules);

    return RulesData(rules: mergedRules, disabledRules: disabledRules);
  }

  Map<String, Object?>? _parseYaml(File file) {
    try {
      final optionsString = file.readAsStringSync();
      final parsed = loadYaml(optionsString);
      if (parsed is! Map) return null;
      return _toStandardMap(parsed);
    } catch (_) {
      return null;
    }
  }

  Map<String, Object?> _toStandardMap(Map<dynamic, dynamic> map) => {
    for (final MapEntry(:key, :value) in map.entries)
      if (key is String) key: _toStandardType(value),
  };

  Object? _toStandardType(Object? value) => switch (value) {
    Map() => _toStandardMap(value),
    Iterable() => value.map(_toStandardType).toList(),
    _ => value,
  };

  void _resolveAndMergeIncludes(
    File baseFile,
    Map<String, Object?> yaml,
    Set<String> seenPaths,
    Map<String, Map<String, Object?>> mergedRules,
    Set<String> disabledRules,
  ) {
    final includeOption = yaml['include'];
    switch (includeOption) {
      case String():
        _resolveAndMergeInclude(
          baseFile,
          includeOption,
          seenPaths,
          mergedRules,
          disabledRules,
        );
      case List():
        for (final include in includeOption) {
          if (include is String) {
            _resolveAndMergeInclude(
              baseFile,
              include,
              seenPaths,
              mergedRules,
              disabledRules,
            );
          }
        }
    }
  }

  void _resolveAndMergeInclude(
    File baseFile,
    String includePath,
    Set<String> seenPaths,
    Map<String, Map<String, Object?>> mergedRules,
    Set<String> disabledRules,
  ) {
    final includedFile = _resolveIncludedFile(baseFile, includePath);
    if (includedFile == null) return;

    final includedData = _parseWithSeen(includedFile, seenPaths);
    for (final MapEntry(key: ruleName, value: includedOptions)
        in includedData.rules.entries) {
      mergedRules[ruleName] = {
        ...?mergedRules[ruleName],
        ...includedOptions,
      };
    }
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
    Map<String, Object?> yaml,
    Map<String, Map<String, Object?>> mergedRules,
    Set<String> disabledRules,
  ) {
    final rawDiagnostics = _extractDiagnostics(yaml);
    if (rawDiagnostics is! Map) return;

    for (final MapEntry(key: ruleName, :value) in rawDiagnostics.entries) {
      if (ruleName is! String) continue;

      switch (value) {
        case Map():
          final existingOptions = mergedRules[ruleName] ?? {};
          mergedRules[ruleName] = <String, Object?>{
            ...existingOptions,
            for (final optionEntry in value.entries)
              if (optionEntry.key is String)
                optionEntry.key as String: optionEntry.value,
          };
          disabledRules.remove(ruleName);
        case bool():
          if (value) {
            disabledRules.remove(ruleName);
          } else {
            mergedRules.remove(ruleName);
            disabledRules.add(ruleName);
          }
        case null:
          disabledRules.remove(ruleName);
      }
    }
  }

  Object? _extractDiagnostics(Map<String, Object?> yaml) {
    final pluginConfig = yaml[SolidLintsConstants.pluginName];
    if (pluginConfig is Map) {
      return pluginConfig['diagnostics'];
    }

    final pluginsConfig = yaml['plugins'];
    if (pluginsConfig is Map) {
      final pluginSubConfig = pluginsConfig[SolidLintsConstants.pluginName];
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
    Map<String, Object?> yaml,
    Map<String, Map<String, Object?>> mergedRules,
    Set<String> disabledRules,
  ) {
    final analyzer = yaml['analyzer'];
    if (analyzer is! Map) return;

    final errors = analyzer['errors'];
    if (errors is! Map) return;

    const pluginPrefix = '${SolidLintsConstants.pluginName}/';

    for (final MapEntry(key: key, value: errorValue) in errors.entries) {
      if (key is! String || !key.startsWith(pluginPrefix)) continue;

      final ruleName = key.substring(pluginPrefix.length);

      if (errorValue == 'ignore' || errorValue == false) {
        mergedRules.remove(ruleName);
        disabledRules.add(ruleName);
      } else {
        disabledRules.remove(ruleName);
      }
    }
  }
}
