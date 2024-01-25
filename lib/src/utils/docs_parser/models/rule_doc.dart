import 'package:solid_lints/src/utils/docs_parser/models/parameter_doc.dart';

/// Lint rule documentation
class RuleDoc {
  /// Rule name
  final String name;

  /// Rule documentation
  final String doc;

  /// Rule parameters
  final List<ParameterDoc> parameters;

  ///
  const RuleDoc({
    required this.name,
    required this.doc,
    required this.parameters,
  });
}
