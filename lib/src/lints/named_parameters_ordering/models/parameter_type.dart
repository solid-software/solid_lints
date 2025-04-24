import 'package:collection/collection.dart';

/// Represents a function parameter type
enum ParameterType {
  /// Inherited (super) parameter type (super.parameterName)
  inherited('super'),

  /// Required inherited (super) parameter type (required super.parameterName)
  requiredInherited('required_super'),

  /// Required parameter type (required String parameterName)
  required('required'),

  /// Nullable parameter type (String? parameterName)
  nullable('nullable'),

  /// Default value parameter type (String parameterName = 'defaultValue')
  defaultValue('default');

  /// Returns [ParameterType] from type or null if not found
  static ParameterType? fromType(String type) {
    return values.firstWhereOrNull((o) => o.type == type);
  }

  /// String representation of the parameter type
  final String type;

  /// Display name of the parameter type
  String get displayName => type.replaceAll('_', ' ');

  const ParameterType(this.type);
}
