import 'package:solid_lints/lints/member_ordering/models/annotation.dart';
import 'package:solid_lints/lints/member_ordering/models/member_type.dart';
import 'package:solid_lints/lints/member_ordering/models/modifier.dart';

/// Abstract class representing class member group
abstract class MemberGroup {
  /// Member annotation (e.g. override, protected)
  final Annotation annotation;

  /// Member  type (e.g. field, method)
  final MemberType memberType;

  /// Member access modifier (e.g. public, private)
  final Modifier modifier;

  /// Raw String representation of class member group
  final String rawRepresentation;

  /// Constructor to use in children extending [MemberGroup]
  const MemberGroup({
    required this.annotation,
    required this.memberType,
    required this.modifier,
    required this.rawRepresentation,
  });

  /// Method to get sorting coefficient of the member group
  int getSortingCoefficient();
}
