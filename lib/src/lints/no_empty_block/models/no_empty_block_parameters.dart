import 'package:solid_lints/src/common/parameters/excluded_identifiers_list_parameter.dart';

/// A data model class that represents the "no empty block" lint input
/// parameters.
class NoEmptyBlockParameters {
  static const _allowCommentsConfig = 'allow_comments';

  /// A list of methods that should be excluded from the lint.
  final ExcludedIdentifiersListParameter exclude;

  /// Whether to exclude empty blocks that contain any comments.
  final bool allowComments;

  /// Constructor for [NoEmptyBlockParameters] model
  NoEmptyBlockParameters({
    required this.exclude,
    required this.allowComments,
  });

  /// Method for creating from json data
  factory NoEmptyBlockParameters.fromJson(Map<String, dynamic> json) {
    return NoEmptyBlockParameters(
      exclude: ExcludedIdentifiersListParameter.defaultFromJson(json),
      allowComments: json[_allowCommentsConfig] as bool? ?? false,
    );
  }
}
