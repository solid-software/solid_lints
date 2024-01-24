import 'dart:io';

import 'package:path/path.dart';
import 'package:solid_lints/utils/docs_parser/models/rule_doc.dart';
import 'package:solid_lints/utils/docs_parser/output_formatters/markdown_formatter.dart';
import 'package:solid_lints/utils/docs_parser/output_formatters/rules_documentation_formatter.dart';

///
class DocusaurusFormatter implements RulesDocumentationFormatter<void> {
  static final _markdownFormatter = MarkdownFormatter();

  ///
  final String docusaurusDocsDirPath;

  ///
  final String outputDirName;

  ///
  final String readmePath;

  final Directory _outputDirectory;
  final Directory _docsDirectory;
  final File _readmeFile;

  ///
  DocusaurusFormatter({
    required this.docusaurusDocsDirPath,
    required this.outputDirName,
    required this.readmePath,
  })  : _outputDirectory = Directory(docusaurusDocsDirPath),
        _docsDirectory = Directory(join(docusaurusDocsDirPath, outputDirName)),
        _readmeFile = File(readmePath);

  @override
  void format(List<RuleDoc> rules) {
    if (_outputDirectory.existsSync()) {
      _outputDirectory.deleteSync(recursive: true);
    }
    _docsDirectory.createSync(recursive: true);

    File(join(docusaurusDocsDirPath, 'intro.md'))
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
