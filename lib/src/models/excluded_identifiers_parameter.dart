/// Model class for ExcludeRule parameters
class ExcludedIdentifiersParameter {
  /// The name of the method that should be excluded from the lint.
  final String methodName;

  /// The name of the class that should be excluded from the lint.
  final String? className;

  /// Constructor for [ExcludedIdentifiersParameter] model
  const ExcludedIdentifiersParameter({
    required this.methodName,
    required this.className,
  });

  ///
  factory ExcludedIdentifiersParameter.fromJson(
    Map<dynamic, dynamic> json,
  ) {
    return ExcludedIdentifiersParameter(
      methodName: json['method_name'] as String,
      className: json['class_name'] as String?,
    );
  }
}
