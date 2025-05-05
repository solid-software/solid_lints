import 'package:solid_lints/src/lints/named_parameters_ordering/models/parameter_type.dart';

/// Data class holds information about parameter order info
class ParameterOrderingInfo {
  /// Indicates if order is wrong
  final bool isWrong;

  /// Info about current parameter parameter type
  final ParameterType parameterType;

  /// Info about previous parameter parameter type
  final ParameterType? previousParameterType;

  /// Creates instance of [ParameterOrderingInfo]
  const ParameterOrderingInfo({
    required this.isWrong,
    required this.parameterType,
    required this.previousParameterType,
  });
}
