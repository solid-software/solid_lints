import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:solid_lints/src/lints/avoid_final_with_getter/avoid_final_with_getter_rule.dart';
import 'package:solid_lints/src/lints/avoid_final_with_getter/visitors/getter_variable_visitor.dart';
import 'package:solid_lints/src/lints/avoid_final_with_getter/visitors/variable_references_visitor.dart';

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
    if (getterNode case MethodDeclaration(
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

      final getterVariableVisitor = GetterVariableVisitor(getterNode);
      compilationUnit.accept(getterVariableVisitor);

      final variableDeclaration = getterVariableVisitor.variable;
      if (variableDeclaration == null) return;

      final referencesVisitor = VariableReferencesVisitor(variableDeclaration);
      compilationUnit.accept(referencesVisitor);

      final variableReferences = referencesVisitor.references;

      final variableName = variableDeclaration.name.lexeme;
      final newPublicVariableName = variableName.startsWith('_')
          ? variableName.substring(1)
          : variableName;

      await builder.addDartFileEdit(file, (builder) {
        builder.addDeletion(getterNode.sourceRange);

        builder.addSimpleReplacement(
          variableDeclaration.name.sourceRange,
          newPublicVariableName,
        );

        for (final reference in variableReferences) {
          if (reference.sourceRange.intersects(getterNode.sourceRange)) {
            continue;
          }

          builder.addSimpleReplacement(
            reference.sourceRange,
            newPublicVariableName,
          );
        }

        builder.format(compilationUnit.sourceRange);
      });
    }
  }
}
