import 'dart:io';

import 'package:path/path.dart';
import 'package:solid_lints/utils/docs_parser/models/rule_doc.dart';
import 'package:solid_lints/utils/docs_parser/output_formatters/markdown_formatter.dart';
import 'package:solid_lints/utils/docs_parser/output_formatters/rules_documentation_formatter.dart';

///
class DocusaurusFormatter implements RulesDocumentationFormatter<void> {
  static final _markdownFormatter = MarkdownFormatter();

  static const _docsDirectoryName = 'Lints Documentation';
  static const _readmeFileName = 'README.md';

  static final _outputDirectoryPath = join(
    Directory.current.path,
    'doc/docusaurus/docs',
  );
  static final _outputDirectory = Directory(_outputDirectoryPath);
  static final _docsDirectory =
      Directory(join(_outputDirectoryPath, _docsDirectoryName));
  static final _readmeFile =
      File(join(Directory.current.path, _readmeFileName));

  @override
  void format(List<RuleDoc> rules) {
    if (_outputDirectory.existsSync()) {
      _outputDirectory.deleteSync(recursive: true);
    }
    _docsDirectory.createSync(recursive: true);

    File(
      join(_outputDirectoryPath, 'intro.md'),
    )
      ..createSync()
      ..writeAsStringSync(_readmeFile.readAsStringSync());

    rules.forEach(_createMarkdownFileForRule);
  }

  void _createMarkdownFileForRule(RuleDoc rule) => File(
        join(_docsDirectory.path, '${rule.name}.md'),
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
