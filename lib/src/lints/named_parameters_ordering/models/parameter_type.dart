import 'package:analyzer/dart/ast/ast.dart';
import 'package:collection/collection.dart';

/// Represents a function parameter type
///
/// @docType String
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

  /// The default ordering of parameter types.
  static const defaultOrder = [
    ParameterType.requiredInherited,
    ParameterType.inherited,
    ParameterType.required,
    ParameterType.nullable,
    ParameterType.defaultValue,
  ];

  /// Returns [ParameterType] from type or null if not found
  static ParameterType? fromType(String type) {
    return values.firstWhereOrNull((o) => o.type == type);
  }

  /// Classifies a [FormalParameter] into a [ParameterType].
  static ParameterType fromParameter(FormalParameter parameter) {
    return switch (parameter) {
      SuperFormalParameter(:final isRequired) =>
        isRequired ? ParameterType.requiredInherited : ParameterType.inherited,
      FormalParameter(defaultClause: _?) => ParameterType.defaultValue,
      FormalParameter(:final isRequired) when isRequired =>
        ParameterType.required,
      _ => ParameterType.nullable,
    };
  }

  /// String representation of the parameter type
  final String type;

  /// Display name of the parameter type
  String get displayName => type.replaceAll('_', ' ');

  const ParameterType(this.type);
}
