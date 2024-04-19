import 'package:solid_lints/src/lints/avoid_returning_widgets/models/avoid_returning_widgets_exclude.dart';

/// A data model class that represents the "avoid returning widgets" input
/// parameters.
class AvoidReturningWidgetsParameters {
  /// A list of methods that should be excluded from the lint.
  final List<AvoidReturningWidgetsExclude> exclude;

  /// Constructor for [AvoidReturningWidgetsParameters] model
  AvoidReturningWidgetsParameters({
    required this.exclude,
  });

  /// Method for creating from json data
  factory AvoidReturningWidgetsParameters.fromJson(Map<String, dynamic> json) {
    final exclude = <AvoidReturningWidgetsExclude>[];

    for (final item in (json['exclude'] as Iterable?) ?? []) {
      if (item is Map && item['method_name'] is String) {
        exclude.add(AvoidReturningWidgetsExclude.fromJson(item));
      }
    }
    return AvoidReturningWidgetsParameters(
      exclude: exclude,
    );
  }
}
