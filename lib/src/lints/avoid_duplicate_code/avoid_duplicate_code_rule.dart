import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/error/error.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/models/avoid_duplicate_code_parameters.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/visitors/avoid_duplicate_code_visitor.dart';
import 'package:solid_lints/src/models/solid_lint_rule.dart';

/// A lint rule that detects duplicated code blocks (clones) across the project.
///
/// When two or more function, method, or constructor bodies or nested code
/// blocks (such as `if` blocks or loops) have structurally identical AST
/// subtrees, the rule reports all copies and provides context messages
/// linking to the other occurrences.
///
/// ### Clone Detection Algorithm
///
/// The rule is built upon the fundamental code clone classification by
/// **Roy & Cordy (2007)** (*"A Survey on Software Clone Detection Research"*):
///
/// :::note Type 2 Clones
/// The rule focuses on **Type 2 clones** (syntactic clones): structurally
/// identical AST subtrees where names of local variables, formal parameters,
/// or literal values may differ. While plain text diff tools only catch exact
/// copies (Type 1), this rule operates on the AST level to detect copy-pasted
/// logic even after variable renaming or code formatting changes.
/// :::
/// :::info Sequential Variable Indexing
/// Local variable and parameter names in the AST subtree are replaced with
/// sequential positional IDs (`0, 1, 2, ...`) based on their first appearance
/// in the code block. This enables the
/// algorithm to recognize identical underlying logic even if variables were
/// renamed (e.g., `x` to `item`).
/// :::
///
/// :::info Structural Hashing
/// Builds an AST subtree fingerprint using **Bob Jenkins' One-at-a-time**
/// **hash** algorithm (structural hashing), which is also utilized in
/// classic static analysis tools like **PMD CPD (Copy-Paste Detector)** and
/// **SonarQube**.
/// :::
///
/// :::info Nested Clone Suppression
/// The algorithm intelligently suppresses overlapping or nested warnings. If a
/// large code block (e.g., an entire function) is identified as a clone, its
/// inner blocks (such as `if` statements or loops) will not be reported
/// separately, preventing warning spam.
/// :::
///
/// ### Best-Effort Sequential Analysis & Caching
///
/// * **Cross-File Analysis (Best-Effort):** Because the Dart Analyzer processes
///   project files sequentially, during the initial analysis pass, only the
///   **second (and subsequent) clone** is highlighted immediately. This happens
///   because the first file was analyzed before information about its copy
///   entered the global registry. The first file will be highlighted upon its
///   next edit, save, or re-analysis.
/// * **Persistent Disk Cache:** The AST block structures and their calculated
///   hashes are cached on disk at
///   `.dart_tool/solid_lints/duplicate_index.json`.
///   Consequently, subsequent IDE sessions or re-analysis passes skip
///   unchanged files, making duplicate code detection significantly faster.
///
/// ### Handling False Positives
///
/// :::warning
/// Due to the nature of AST structural analysis, false positives may
/// occasionally occur on repetitive boilerplate code sharing identical
/// structural flow (such as form initializers, DTO mappers, UI builder methods,
/// or lifecycle hooks like `initState` and `dispose`).
/// :::
///
/// If you encounter false positive warnings in your project, consider the
/// following solutions:
///
/// 1. **Ignore specific occurrences in code:** Use inline analysis ignore
///    comments above the affected method:
///    ```dart
///    // ignore: avoid_duplicate_code
///    void myBoilerplateMethod() { ... }
///    ```
/// 2. **Exclude methods globally:** Add the method name to the `exclude` list
///    in your `analysis_options.yaml` config (e.g., excluding `initState` or
///    `dispose`).
/// 3. **Increase `min_tokens` threshold:** Raise the `min_tokens` parameter
///    (e.g., to `40` or `50`) to ignore shorter structural clones across the
///    project.
///
/// ### Example config:
///
/// ```yaml
/// plugins:
///   solid_lints:
///     diagnostics:
///       avoid_duplicate_code:
///         min_tokens: 30
///         ignore_literals: false
///         ignore_identifiers: true
///         check_blocks: true
///         exclude:
///           - method_name: initState
///           - method_name: dispose
/// ```
class AvoidDuplicateCodeRule
    extends SolidLintRule<AvoidDuplicateCodeParameters> {
  /// Name of the lint.
  static const lintName = 'avoid_duplicate_code';

  static const _code = LintCode(
    lintName,
    'Perhaps this code is a duplicate.\n'
    'Consider extracting the shared logic into a common function.',
  );

  @override
  DiagnosticCode get diagnosticCode => _code;

  /// Creates a new instance of [AvoidDuplicateCodeRule].
  AvoidDuplicateCodeRule({
    required super.analysisOptionsLoader,
  }) : super.withParameters(
         name: lintName,
         description:
             'Detects structurally identical function/method bodies '
             'within a single file and across files (code clones).',
         parametersParser: AvoidDuplicateCodeParameters.fromJson,
       );

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    super.registerNodeProcessors(registry, context);

    final parameters =
        getParametersForContext(context) ??
        AvoidDuplicateCodeParameters.empty();

    final visitor = AvoidDuplicateCodeVisitor(
      this,
      parameters,
      filePath: context.definingUnit.file.path,
      modificationStamp: context.definingUnit.file.modificationStamp,
      contextRoot: context.libraryElement?.session.analysisContext.contextRoot,
      resourceProvider: context.definingUnit.file.provider,
    );

    registry.addCompilationUnit(this, visitor);
  }
}
