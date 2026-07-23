import 'package:analyzer/dart/ast/ast.dart';
import 'package:solid_lints/src/lints/member_ordering/models/member_order.dart';

/// Data class that holds AST class member and it's order info
class MemberInfo {
  /// AST instance of an [ClassMember]
  final ClassMember classMember;

  /// Class member order info
  final MemberOrder memberOrder;

  /// Creates instance of an [MemberInfo]
  const MemberInfo({
    required this.classMember,
    required this.memberOrder,
  });
}
