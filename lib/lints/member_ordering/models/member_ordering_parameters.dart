import 'package:solid_lints/lints/member_ordering/config_parser.dart';
import 'package:solid_lints/lints/member_ordering/models/member_group.dart';

/// A data model class that represents the member ordering input
/// parameters.
class MemberOrderingParameters {
  /// Config keys
  static const _orderConfig = 'order';
  static const _widgetsOrderConfig = 'widgets-order';
  static const _alphabetizeConfig = 'alphabetize';
  static const _alphabetizeByTypeConfig = 'alphabetize-by-type';

  /// Config used for members of regular class
  final List<MemberGroup> groupsOrder;

  /// Config used for members of widget class
  final List<MemberGroup> widgetsGroupsOrder;

  /// Indicates if params should be in alphabetical order
  final bool alphabetize;

  /// Indicates if params should be in alphabetical order of their type
  final bool alphabetizeByType;

  /// Constructor for [MemberOrderingParameters] model
  const MemberOrderingParameters({
    required this.groupsOrder,
    required this.widgetsGroupsOrder,
    required this.alphabetize,
    required this.alphabetizeByType,
  });

  /// Method for creating from json data
  factory MemberOrderingParameters.fromJson(Map<String, Object?> json) =>
      MemberOrderingParameters(
        groupsOrder: MemberOrderingConfigParser.parseOrder(json[_orderConfig]),
        widgetsGroupsOrder: MemberOrderingConfigParser.parseWidgetsOrder(
          json[_widgetsOrderConfig],
        ),
        alphabetize: json[_alphabetizeConfig] as bool? ?? false,
        alphabetizeByType: json[_alphabetizeByTypeConfig] as bool? ?? false,
      );
}
