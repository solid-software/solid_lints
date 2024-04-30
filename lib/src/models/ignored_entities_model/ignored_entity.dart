/// An entity (method/function/class) to be excluded from lint
class IgnoredEntity {
  IgnoredEntity._({
    this.className,
    this.functionName,
  });

  ///
  factory IgnoredEntity.fromJson(Map<dynamic, dynamic> json) {
    return IgnoredEntity._(
      className: json['class_name'] as String?,
      functionName: json['method_name'] as String?,
    );
  }

  /// Class name
  final String? className;
  /// Function name
  final String? functionName;

  @override
  String toString() {
    return "$className: $functionName";
  }
}
