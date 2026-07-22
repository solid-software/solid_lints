import 'package:equatable/equatable.dart';

/// Model class for ExcludeRule parameters
class ExcludedIdentifierParameter extends Equatable {
  /// The name of the method that should be excluded from the lint.
  final String? methodName;

  /// The name of the class that should be excluded from the lint.
  final String? className;

  /// The name of the plain Strings that should be excluded from the lint
  final String? declarationName;

  /// Constructor for [ExcludedIdentifierParameter] model
  const ExcludedIdentifierParameter({
    this.methodName,
    this.className,
    this.declarationName,
  });

  ///
  factory ExcludedIdentifierParameter.fromJson(
    Map<dynamic, dynamic> json,
  ) {
    return ExcludedIdentifierParameter(
      methodName: json['method_name'] as String?,
      className: json['class_name'] as String?,
      declarationName: json['declaration_name'] as String?,
    );
  }

  /// Method to convert parameter to JSON Map.
  Map<String, Object?> toJson() => {
    'method_name': ?methodName,
    'class_name': ?className,
    'declaration_name': ?declarationName,
  };

  @override
  List<Object?> get props => [methodName, className, declarationName];
}
