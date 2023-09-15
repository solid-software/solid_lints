import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';

/// Check node is override method from its metadata
bool isOverride(List<Annotation> metadata) => metadata.any(
      (node) =>
          node.name.name == 'override' && node.atSign.type == TokenType.AT,
    );
