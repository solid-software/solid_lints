import 'dart:io';
import 'package:yaml/yaml.dart';

/// Loads and parses analysis options from a Dart project's YAML file.
class AnalysisOptionsLoader {
  final Map<String, dynamic> _cache = {};

  /// Loads analysis options from a YAML file at the given [yamlPath].
  Map<String, dynamic> loadAnalysisOptions(String yamlPath) {
    if (_cache.containsKey(yamlPath)) {
      return _cache[yamlPath] as Map<String, dynamic>;
    }

    final file = File(yamlPath);
    if (!file.existsSync()) {
      _cache[yamlPath] = {};
      return {};
    }

    try {
      final content = file.readAsStringSync();
      final yamlMap = loadYaml(content);
      final parsedYaml = _convertYaml(yamlMap);
      final result =
          parsedYaml is Map<String, dynamic> ? parsedYaml : <String, dynamic>{};

      _cache[yamlPath] = result;
      return result;
    } on YamlException {
      _cache[yamlPath] = {};
      return {};
    }
  }

  /// Extracts custom lint rules from the provided YAML map.
  Map<String, dynamic> extractLintRules(
    Map<String, dynamic> yaml, {
    String lintName = 'custom_lint',
  }) {
    final customLint = yaml[lintName];

    if (customLint is! Map) return {};

    final rules = customLint['rules'];

    if (rules is! List) return {};

    final result = <String, dynamic>{};

    for (final item in rules) {
      final rule = _extractRuleEntry(item);
      if (rule == null) continue;

      result[rule.$1] = rule.$2;
    }

    return result;
  }

  dynamic _convertYaml(dynamic yaml) {
    if (yaml is YamlMap) {
      return _yamlMapToDartMap(yaml);
    }

    if (yaml is YamlList) {
      return yaml.map(_convertRuleItem).toList();
    }

    return yaml;
  }

  dynamic _convertRuleItem(dynamic item) {
    if (item is! YamlMap) return item;

    final map = _yamlMapToDartMap(item);

    final keys = map.keys.toList();

    if (keys.length >= 2 && map[keys.first] == null) {
      final ruleName = keys.first;
      final config = Map<String, dynamic>.from(map)..remove(ruleName);

      return {ruleName: config.isEmpty ? null : config};
    }

    return map;
  }

  Map<String, dynamic> _yamlMapToDartMap(YamlMap yamlMap) {
    return Map<String, dynamic>.fromEntries(
      yamlMap.entries.map(
        (e) => MapEntry(e.key.toString(), _convertYaml(e.value)),
      ),
    );
  }

  (String, Map<String, dynamic>)? _extractRuleEntry(dynamic item) {
    if (item is String) return (item, {});
    if (item is! Map || item.isEmpty) return null;

    final entry = item.entries.first;
    final ruleName = entry.key.toString();
    final config = entry.value;

    if (config is Map<String, dynamic>) {
      return (ruleName, config);
    }

    if (config is Map) {
      return (ruleName, Map<String, dynamic>.from(config));
    }

    return (ruleName, {});
  }
}
