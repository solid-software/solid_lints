import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:solid_lints/src/lints/avoid_final_with_getter/avoid_final_with_getter_rule.dart';
import 'package:solid_lints/src/lints/avoid_final_with_getter/visitors/getter_variable_visitor.dart';

/// A Quick fix for [AvoidFinalWithGetterRule] rule
class AvoidFinalWithGetterFix extends ResolvedCorrectionProducer {
  static const _avoidFinalWithGetterKind = FixKind(
    'solid_lints.fix.${AvoidFinalWithGetterRule.lintName}',
    DartFixKindPriority.standard,
    "Remove the getter and make the field public",
  );

  /// Creates a new instance of [AvoidFinalWithGetterFix]
  AvoidFinalWithGetterFix({required super.context});

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.acrossFiles;

  @override
  FixKind get fixKind => _avoidFinalWithGetterKind;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final getterNode = node;
    if (getterNode
        case MethodDeclaration(
          isGetter: true,
          declaredFragment: ExecutableFragment(
            element: GetterElement(
              isAbstract: false,
              isPublic: true,
            ),
          ),
        )) {
      final compilationUnit = node.thisOrAncestorOfType<CompilationUnit>();
      if (compilationUnit == null) return;

      final visitor = GetterVariableVisitor(getterNode);
      compilationUnit.accept(visitor);

      final variableDeclaration = visitor.variable;
      if (variableDeclaration == null) return;

      final variablePrivatePrefixRange =
          SourceRange(variableDeclaration.name.offset, 1);

      await builder.addDartFileEdit(file, (builder) {
        builder.addDeletion(getterNode.sourceRange);
        builder.addDeletion(variablePrivatePrefixRange);

        builder.format(compilationUnit.sourceRange);
      });
    }
  }
}
