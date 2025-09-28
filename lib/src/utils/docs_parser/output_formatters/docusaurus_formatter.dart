import 'dart:io';

import 'package:path/path.dart';
import 'package:solid_lints/src/utils/docs_parser/models/rule_doc.dart';
import 'package:solid_lints/src/utils/docs_parser/output_formatters/markdown_formatter.dart';
import 'package:solid_lints/src/utils/docs_parser/output_formatters/rules_documentation_formatter.dart';

/// Formatter that generates markdown files for every separate rule
class DocusaurusFormatter implements RulesDocumentationFormatter<void> {
  static const _introFileMetadata = '''
---
sidebar_label: Overview
sidebar_position: 0
---  


''';
  static final _markdownFormatter = MarkdownFormatter();

  final Directory _outputDirectory;
  final File _readmeFile;

  /// DocusaurusFormatter
  DocusaurusFormatter({
    required String docusaurusDocsDirPath,
    required String readmePath,
  }) : _outputDirectory = Directory(docusaurusDocsDirPath),
       _readmeFile = File(readmePath);

  @override
  void format(List<RuleDoc> rules) {
    if (!_outputDirectory.existsSync()) {
      _outputDirectory.createSync(recursive: true);
    }

    File(join(_outputDirectory.parent.path, 'intro.md'))
      ..createSync()
      ..writeAsStringSync(_introFileMetadata + _readmeFile.readAsStringSync());

    rules.forEach(_createMarkdownFileForRule);
  }

  void _createMarkdownFileForRule(RuleDoc rule) =>
      File(
          join(_outputDirectory.path, '${rule.name}.md'),
        )
        ..createSync()
        ..writeAsString(
          _markdownFormatter.formatRuleToMarkdown(
            rule,
            includeName: false,
            parametersAsList: false,
          ),
        );
}
