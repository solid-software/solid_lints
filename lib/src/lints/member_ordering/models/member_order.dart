import 'package:solid_lints/src/lints/member_ordering/models/member_group/member_group.dart';
import 'package:solid_lints/src/lints/member_ordering/models/member_names.dart';

/// Data class holds information about class member order info
class MemberOrder {
  /// Indicates if order is wrong
  final bool isWrong;

  /// Indicates if order is wrong alphabetically
  final bool isAlphabeticallyWrong;

  /// Indicates if order is wrong alphabetically by type
  final bool isByTypeWrong;

  /// Info about current and previous class member name
  final MemberNames memberNames;

  /// Info about current member member group
  final MemberGroup memberGroup;

  /// Info about previous member member group
  final MemberGroup? previousMemberGroup;

  /// Creates instance of [MemberOrder]
  const MemberOrder({
    required this.isWrong,
    required this.isAlphabeticallyWrong,
    required this.isByTypeWrong,
    required this.memberNames,
    required this.memberGroup,
    this.previousMemberGroup,
  });
}
