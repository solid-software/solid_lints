import 'dart:io';

import 'package:path/path.dart';
import 'package:solid_lints/src/utils/docs_parser/models/rule_doc.dart';
import 'package:solid_lints/src/utils/docs_parser/output_formatters/markdown_formatter.dart';
import 'package:solid_lints/src/utils/docs_parser/output_formatters/rules_documentation_formatter.dart';
import 'package:yaml/yaml.dart';

/// Formatter that generates markdown files for every separate rule
class DocusaurusFormatter implements RulesDocumentationFormatter<void> {
  static const _introFileMetadata = '''
---
sidebar_label: Overview
sidebar_position: 0
---  


''';
  static const _latestVersionPlaceholder = '<INSERT LATEST VERSION>';
  static final _markdownFormatter = MarkdownFormatter();

  final Directory _outputDirectory;
  final File _readmeFile;
  final File _pubspecFile;

  /// DocusaurusFormatter
  DocusaurusFormatter({
    required String docusaurusDocsDirPath,
    required String readmePath,
    required String pubspecPath,
  }) : _outputDirectory = Directory(docusaurusDocsDirPath),
       _readmeFile = File(readmePath),
       _pubspecFile = File(pubspecPath);

  @override
  void format(List<RuleDoc> rules) {
    if (!_outputDirectory.existsSync()) {
      _outputDirectory.createSync(recursive: true);
    }

    final stableVersion = _extractStableVersion();
    final readmeContent = _readmeFile.readAsStringSync().replaceAll(
      _latestVersionPlaceholder,
      stableVersion ?? _latestVersionPlaceholder,
    );

    File(
      join(_outputDirectory.parent.path, 'intro.md'),
    ).writeAsStringSync('$_introFileMetadata$readmeContent');

    rules.forEach(_createMarkdownFileForRule);
  }

  String? _extractStableVersion() {
    if (!_pubspecFile.existsSync()) return null;
    try {
      final yaml = loadYaml(_pubspecFile.readAsStringSync());
      if (yaml case {'version': final String rawVersion}) {
        return '^${rawVersion.split(RegExp('[-+]')).first}';
      }
    } catch (_) {}
    return null;
  }

  void _createMarkdownFileForRule(RuleDoc rule) =>
      File(join(_outputDirectory.path, '${rule.name}.md')).writeAsStringSync(
        _markdownFormatter.formatRuleToMarkdown(
          rule,
          includeName: false,
          parametersAsList: false,
        ),
      );
}
