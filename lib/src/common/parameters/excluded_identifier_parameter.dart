/// Model class for ExcludeRule parameters
class ExcludedIdentifierParameter {
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
      methodName: json['method_name'] as String,
      className: json['class_name'] as String?,
    );
  }
}
