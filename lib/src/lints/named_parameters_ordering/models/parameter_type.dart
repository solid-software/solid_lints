/// Represents a function parameter type
enum ParameterType {
  /// Super parameter type (super.parameterName)
  super$('super'),

  /// Required super parameter type (required super.parameterName)
  requiredSuper('required_super'),

  /// Required parameter type (required String parameterName)
  required('required'),

  /// Nullable parameter type (String? parameterName)
  nullable('nullable'),

  /// Default parameter type (String parameterName = 'defaultValue')
  default$('default');

  /// String representation of the parameter type
  final String type;

  /// Display name of the parameter type
  String get displayName => type.replaceAll('_', ' ');

  const ParameterType(this.type);
}
