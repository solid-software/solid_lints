import 'dart:io';

import 'package:path/path.dart';
import 'package:solid_lints/src/utils/docs_parser/output_formatters/markdown_formatter.dart';
import 'package:solid_lints/src/utils/docs_parser/parsers/docs_parser.dart';

void main() {
  final dir = Directory(
    normalize(join(Directory.current.path, 'lib', 'src', 'lints')),
  );

  final parser = DocsParser(
    formatter: MarkdownFormatter(),
    ruleFileSuffixes: const ['rule', 'metric'],
  );

  final result = parser.parse(dir);
  File('DOCUMENTATION.md').writeAsStringSync(result);
}
