import 'package:analyzer/dart/element/type.dart';
import 'package:collection/collection.dart';
import 'package:solid_lints/src/utils/types_utils.dart';

/// A parameter model representing ignored types for linting.
/// It defines types that indicate when expressions, variables, or return values
/// should be ignored during analysis.
///
/// @docType String | List<String> | Map<String, Object?>
class IgnoredTypesListParameter {
  /// The set of ignored type names.
  final Set<String> ignoredTypes;

  /// A common parameter key for analysis_options.yaml
  static const String ignoredTypesKey = 'ignored_types';

  /// Constructor for [IgnoredTypesListParameter] class.
  const IgnoredTypesListParameter({
    required this.ignoredTypes,
  });

  /// Empty [IgnoredTypesListParameter] model.
  factory IgnoredTypesListParameter.empty() => const IgnoredTypesListParameter(
    ignoredTypes: {},
  );

  /// Method for creating from json data.
  factory IgnoredTypesListParameter.fromJson(Map<String, Object?> json) {
    final raw = json[ignoredTypesKey];
    final types = switch (raw) {
      final Iterable<Object?> list => list.whereType<String>().toSet(),
      final Map<Object?, Object?> map => map.keys.whereType<String>().toSet(),
      final String str => {str},
      _ => const <String>{},
    };

    return IgnoredTypesListParameter(ignoredTypes: types);
  }

  /// Returns whether the target type should be ignored during analysis.
  bool shouldIgnore(DartType? type) {
    if (type == null || ignoredTypes.isEmpty) return false;
    return type.hasIgnoredType(ignoredTypes: ignoredTypes);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IgnoredTypesListParameter &&
          const SetEquality<String>().equals(
            other.ignoredTypes,
            ignoredTypes,
          );

  @override
  int get hashCode => const SetEquality<String>().hash(ignoredTypes);
}
