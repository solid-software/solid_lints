import 'dart:io';

import 'package:path/path.dart';
import 'package:solid_lints/utils/docs_parser/output_formatters/docusaurus_formatter.dart';
import 'package:solid_lints/utils/docs_parser/parsers/docs_parser.dart';

void main() async => DocsParser(
      formatter: DocusaurusFormatter(),
    ).parse(
      Directory(
        normalize(
          join(Directory.current.path, 'lib', 'lints'),
        ),
      ),
    );
