import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart';
import 'package:solid_lints/utils/docs_parser/output_formatters/docusaurus_formatter.dart';
import 'package:solid_lints/utils/docs_parser/parsers/docs_parser.dart';

void main(List<String> rawArgs) async {
  final readmeDefaultPath = join(Directory.current.parent.path, 'README.md');
  final docusaurusDefaultPath = join(
    Directory.current.parent.path,
    'doc',
    'docusaurus',
    'docs',
  );

  final argsParser = ArgParser()
    ..addOption(
      'path',
      abbr: 'p',
      help: 'Path to the directory containing lint rules',
      mandatory: true,
    )
    ..addOption(
      'docs-dir',
      abbr: 'o',
      help: 'Parser output path. i.e "docusaurus/docs" directory',
      defaultsTo: docusaurusDefaultPath,
    )
    ..addOption(
      'output-dirname',
      abbr: 'n',
      help: 'Output directory name for generated lints documentation files',
      defaultsTo: 'Lints Documentation',
    )
    ..addOption(
      'readme',
      abbr: 'r',
      help: 'Path to the README.md file that should be'
          ' copied as docusaurus intro.md',
      defaultsTo: readmeDefaultPath,
    )
    ..addFlag(
      'sort-rules',
      abbr: 's',
      help: 'Sort rules alphabetically',
      negatable: false,
    )
    ..addMultiOption(
      'suffixes',
      help: 'Filename suffixes that should be parsed',
      defaultsTo: ['rule', 'metric'],
    )
    ..addFlag('help', negatable: false);

  final args = argsParser.parse(rawArgs);
  if (args.wasParsed('help')) {
    return print(argsParser.usage);
  }

  final path = normalize(absolute(args['path']));
  DocsParser(
    formatter: DocusaurusFormatter(
      docusaurusDocsDirPath: args['docs-dir'],
      outputDirName: args['output-dirname'],
      readmePath: args['readme'],
    ),
    ruleFileSuffixes: args['suffixes'],
  ).parse(
    Directory(path),
    sortRulesAlphabetically: args['sort-rules'],
  );
}
