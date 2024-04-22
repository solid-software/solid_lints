/// Model class for AvoidReturningWidgetsExclude parameters
class AvoidReturningWidgetsExclude {
  /// The name of the method that should be excluded from the lint.
  final String methodName;

  /// The name of the class that should be excluded from the lint.
  final String? className;

  /// Constructor for [AvoidReturningWidgetsExclude] model
  const AvoidReturningWidgetsExclude({
    required this.methodName,
    required this.className,
  });

  ///
  factory AvoidReturningWidgetsExclude.fromJson(
    Map<dynamic, dynamic> json,
  ) {
    return AvoidReturningWidgetsExclude(
      methodName: json['method_name'] as String,
      className: json['class_name'] as String?,
    );
  }
}
