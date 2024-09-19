import 'package:analyzer/dart/ast/ast.dart' show AnnotatedNode, Identifier;
import 'package:collection/collection.dart';
import 'package:solid_lints/src/lints/member_ordering/models/annotation.dart';
import 'package:solid_lints/src/lints/member_ordering/models/modifier.dart';

/// Parses [AnnotatedNode] and creates an instance of [Annotation]
Annotation? parseAnnotation(AnnotatedNode node) {
  return node.metadata
      .map((metadata) => Annotation.parse(metadata.name.name))
      .nonNulls
      .firstOrNull;
}

/// Parses class memberName and return it's access [Modifier]
Modifier parseModifier(String? memberName) {
  if (memberName == null) return Modifier.unset;

  return Identifier.isPrivateName(memberName)
      ? Modifier.private
      : Modifier.public;
}
