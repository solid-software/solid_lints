import 'package:solid_lints/src/common/parameters/excluded_identifiers_list_parameter.dart';

/// A data model class that represents the "no empty block" lint input
/// parameters.
class NoEmptyBlockParameters {
  static const _allowWithCommentsConfig = 'allow_with_comments';

  /// A list of methods that should be excluded from the lint.
  final ExcludedIdentifiersListParameter exclude;

  /// Whether to exclude empty blocks that contain any comments.
  final bool allowWithComments;

  /// Constructor for [NoEmptyBlockParameters] model
  NoEmptyBlockParameters({
    required this.exclude,
    required this.allowWithComments,
  });

  /// Method for creating from json data
  factory NoEmptyBlockParameters.fromJson(Map<String, dynamic> json) {
    return NoEmptyBlockParameters(
      exclude: ExcludedIdentifiersListParameter.defaultFromJson(json),
      allowWithComments: json[_allowWithCommentsConfig] as bool? ?? false,
    );
  }
}
