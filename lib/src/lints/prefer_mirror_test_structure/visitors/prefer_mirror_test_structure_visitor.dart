import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:path/path.dart' as p;
import 'package:solid_lints/src/lints/prefer_mirror_test_structure/prefer_mirror_test_structure_rule.dart';

/// The AST visitor that checks if test files mirror the folder structure of
/// their corresponding implementation files.
class PreferMirrorTestStructureVisitor extends SimpleAstVisitor<void> {
  static const _testSuffix = '_test.dart';
  static const _dartSuffix = '.dart';
  static const _testDirName = 'test';
  static const _libDirName = 'lib';

  /// The rule that instantiated this visitor.
  final PreferMirrorTestStructureRule rule;

  /// The context of the current analysis rule.
  final RuleContext context;

  /// Creates a new instance of [PreferMirrorTestStructureVisitor].
  PreferMirrorTestStructureVisitor({
    required this.rule,
    required this.context,
  });

  @override
  void visitCompilationUnit(CompilationUnit node) {
    final currentUnit = context.currentUnit;
    final packageRoot = context.package?.root.path;
    if (currentUnit == null ||
        packageRoot == null ||
        !context.isInTestDirectory) {
      return;
    }

    final file = currentUnit.file;
    final fileName = file.shortName;
    if (!fileName.endsWith(_testSuffix)) return;

    final pathContext = file.provider.pathContext;
    final testDir = pathContext.relative(
      file.parent.path,
      from: pathContext.join(packageRoot, _testDirName),
    );

    final libRoot = pathContext.join(packageRoot, _libDirName);
    final targetFileName = fileName.replaceFirst(_testSuffix, _dartSuffix);

    for (final directive in node.directives.whereType<ImportDirective>()) {
      if (directive.libraryImport?.uri case DirectiveUriWithSource(
        :final source,
      )) {
        final importedPath = source.fullName;
        if (pathContext.basename(importedPath) != targetFileName ||
            !pathContext.isWithin(libRoot, importedPath)) {
          continue;
        }

        final libDir = pathContext.relative(
          pathContext.dirname(importedPath),
          from: libRoot,
        );
        if (libDir == testDir) return;

        final nativePath = pathContext.normalize(
          pathContext.join(_testDirName, libDir, fileName),
        );
        currentUnit.diagnosticReporter.atNode(
          directive.uri,
          rule.diagnosticCode,
          arguments: [p.posix.joinAll(pathContext.split(nativePath))],
        );

        return;
      }
    }
  }
}
