
/// Model class for ExcludeRule parameters
class ExcludeRule {
  /// The name of the method that should be excluded from the lint.
  final String methodName;

  /// The name of the class that should be excluded from the lint.
  final String? className;

  /// Constructor for [ExcludeRule] model
  const ExcludeRule({
    required this.methodName,
    required this.className,
  });

  ///
  factory ExcludeRule.fromJson(
    Map<dynamic, dynamic> json,
  ) {
    return ExcludeRule(
      methodName: json['method_name'] as String,
      className: json['class_name'] as String?,
    );
  }
}
