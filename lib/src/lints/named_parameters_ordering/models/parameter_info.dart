import 'package:analyzer/dart/ast/ast.dart';
import 'package:solid_lints/src/lints/named_parameters_ordering/models/parameter_ordering_info.dart';

/// Data class that holds AST function parameter and it's order info
class ParameterInfo {
  /// AST instance of an [FormalParameter]
  final FormalParameter formalParameter;

  /// Function parameter order info
  final ParameterOrderingInfo parameterOrderingInfo;

  /// Creates instance of an [ParameterInfo]
  const ParameterInfo({
    required this.formalParameter,
    required this.parameterOrderingInfo,
  });
}
