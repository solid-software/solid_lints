/// Data class contains info about current and previous class member names
class MemberNames {
  /// Name of current class member
  final String currentName;

  /// Name of previous class member
  final String? previousName;

  /// Type name of current class member
  final String currentTypeName;

  /// Type name of previous class member
  final String? previousTypeName;

  /// Creates instance of [MemberNames]
  const MemberNames({
    required this.currentName,
    required this.currentTypeName,
    this.previousName,
    this.previousTypeName,
  });
}
