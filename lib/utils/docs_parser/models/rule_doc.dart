import 'package:solid_lints/utils/docs_parser/models/parameter_doc.dart';

/// RuleDoc class defining documentation for the single linter rule
class RuleDoc {
  /// Rule name
  final String name;

  /// Rule documentation
  final String doc;

  /// Rule parameters
  final List<ParameterDoc> parameters;

  /// RuleDoc constructor
  const RuleDoc({
    required this.name,
    required this.doc,
    required this.parameters,
  });
}
