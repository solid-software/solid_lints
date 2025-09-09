import 'dart:io';

import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:solid_lints/src/models/rule_config.dart';
import 'package:solid_lints/src/utils/path_utils.dart';
import 'package:yaml/yaml.dart';

/// A base class for emitting information about
/// issues with user's `.dart` files.
abstract class SolidLintRule<T extends Object?> extends DartLintRule {
  /// Constructor for [SolidLintRule] model.
  SolidLintRule(this.config) : super(code: config.lintCode);

  /// Configuration for a particular rule with all the
  /// defined custom parameters.
  final RuleConfig<T> config;

  /// A flag which indicates whether this rule was enabled by the user (globally).
  bool get enabled => config.enabled;

  @override
  void run(CustomLintResolver resolver,
      ErrorReporter reporter,
      CustomLintContext context,) {
    if (!isEnabledForFile(resolver.path)) return;
    runRule(resolver, reporter, context);
  }

  /// Override this method instead of run() in your rule implementations
  void runRule(CustomLintResolver resolver,
      ErrorReporter reporter,
      CustomLintContext context,);

  /// Determines if the rule should run for the given file.
  bool isEnabledForFile(String filePath) {
    if (!enabled) return false;
    if (_isTestFile(filePath) && _isRuleDisabledInLocalConfig(filePath)) {
      return false;
    }
    return true;
  }

  /// Checking if the file is a test file.
  bool _isTestFile(String filePath) {
    return filePath.contains('/test/') ||
        filePath.contains(r'\test\') ||
        filePath.endsWith('_test.dart');
  }

  /// Check if rule is disabled in local analysis_options.yaml config.
  bool _isRuleDisabledInLocalConfig(String filePath) {
    final configPath = findAnalysisOptionsForFile(filePath);
    if (configPath == null) return false;

    try {
      final file = File(configPath);
      if (!file.existsSync()) return false;

      final content = file.readAsStringSync();
      final yaml = loadYaml(content) as Map<String, dynamic>?;

      if (yaml == null) return false;

      final customLint = yaml['custom_lint'] as Map<String, dynamic>?;
      if (customLint == null) return false;

      final rules = customLint['rules'] as List?;
      if (rules == null) return false;

      /// Searching rule in rules list
      for (final rule in rules) {
        if (rule is String && rule == config.name) {
          return false;
        } else if (rule is Map) {
          final key = rule.keys.first as String;
          if (key == config.name) {
            final value = rule.values.first;
            return value == false;
          }
        }
      }

      return false;
    } catch (e) {
      return false;
    }
  }
}
