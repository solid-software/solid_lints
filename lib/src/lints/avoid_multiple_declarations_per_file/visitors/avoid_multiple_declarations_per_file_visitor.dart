import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/source/line_info.dart';
import 'package:collection/collection.dart';
import 'package:solid_lints/src/lints/avoid_multiple_declarations_per_file/avoid_multiple_declarations_per_file_rule.dart';
import 'package:solid_lints/src/lints/avoid_multiple_declarations_per_file/models/avoid_multiple_declarations_per_file_parameters.dart';
import 'package:solid_lints/src/utils/file_name_matcher.dart';
import 'package:solid_lints/src/utils/node_utils.dart';

/// The AST visitor that reports multiple top-level nominal declarations in a
/// single file.
class AvoidMultipleDeclarationsPerFileVisitor extends SimpleAstVisitor<void> {
  /// The rule that instantiated this visitor.
  final AvoidMultipleDeclarationsPerFileRule rule;

  /// Configuration parameters for this rule.
  final AvoidMultipleDeclarationsPerFileParameters parameters;

  /// Creates a new instance of [AvoidMultipleDeclarationsPerFileVisitor].
  AvoidMultipleDeclarationsPerFileVisitor({
    required this.rule,
    required this.parameters,
  });

  @override
  void visitCompilationUnit(CompilationUnit node) {
    final declarations = node.declarations
        .where((d) => d.isNominalDeclaration)
        .whereNot(parameters.shouldIgnore)
        .toList();

    if (declarations.length <= 1) return;

    final primary = _findPrimaryDeclaration(
      declarations,
      node.declaredFragment?.source.fullName,
    );

    final violations = declarations
        .where((c) => c != primary)
        .whereNot((c) => parameters.allowPrivate && c.isPrivate)
        .whereNot((c) => _isSubclassOfSealed(c, node.sealedClassNames))
        .whereNot((c) => _isUnderMaxLoc(c, node.lineInfo));

    for (final violation in violations) {
      rule.reportAtToken(
        violation.declarationToken ?? violation.beginToken,
        arguments: [violation.displayName],
      );
    }
  }

  CompilationUnitMember _findPrimaryDeclaration(
    List<CompilationUnitMember> declarations,
    String? filePath,
  ) {
    final targetName = FileNameMatcher.normalizePath(filePath);

    return declarations.firstWhereOrNull(
          (d) =>
              targetName.isNotEmpty &&
              targetName == FileNameMatcher.normalizeIdentifier(d.displayName),
        ) ??
        declarations.firstWhereOrNull((d) => !d.isPrivate) ??
        declarations.first;
  }

  bool _isSubclassOfSealed(
    CompilationUnitMember candidate,
    Set<String> sealedNames,
  ) => candidate.supertypeNames.any(sealedNames.contains);

  bool _isUnderMaxLoc(CompilationUnitMember node, LineInfo lineInfo) {
    final maxLoc = parameters.maximumLoc ?? 0;
    return maxLoc > 0 && node.calculateLoc(lineInfo) <= maxLoc;
  }
}
