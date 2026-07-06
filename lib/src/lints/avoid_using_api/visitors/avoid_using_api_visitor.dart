import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/syntactic_entity.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:solid_lints/src/lints/avoid_using_api/avoid_using_api_rule.dart';
import 'package:solid_lints/src/lints/avoid_using_api/models/avoid_using_api_entry_parameters.dart';
import 'package:solid_lints/src/lints/avoid_using_api/models/avoid_using_api_parameters.dart';
import 'package:solid_lints/src/utils/node_utils.dart';
import 'package:solid_lints/src/utils/path_utils.dart';

/// The AST visitor that checks for avoided API usages.
class AvoidUsingApiVisitor extends SimpleAstVisitor<void> {
  /// The default constructor identifier representation.
  static const String _defaultConstructorIdentifier = '()';

  /// The parameters configuration.
  final AvoidUsingApiParameters parameters;

  /// The rule context.
  final RuleContext context;

  List<AvoidUsingApiEntryParameters>? _cachedActiveEntries;

  /// Creates a new instance of [AvoidUsingApiVisitor].
  AvoidUsingApiVisitor({
    required this.parameters,
    required this.context,
  });

  List<AvoidUsingApiEntryParameters> _getActiveEntries(
    String filePath,
    String? rootPath,
  ) {
    return parameters.entries.where((entry) {
      return !shouldSkipFile(
        includeGlobs: entry.includes,
        excludeGlobs: entry.excludes,
        path: filePath,
        rootPath: rootPath,
      );
    }).toList();
  }

  ({
    List<AvoidUsingApiEntryParameters> activeEntries,
    DiagnosticReporter reporter,
  })?
  _resolveContext() {
    final currentUnit = context.currentUnit;
    if (currentUnit == null) return null;

    final activeEntries = _cachedActiveEntries ??= _getActiveEntries(
      currentUnit.file.path,
      context.package?.root.path,
    );

    return (
      activeEntries: activeEntries,
      reporter: currentUnit.diagnosticReporter,
    );
  }

  LintCode _getLintCode(AvoidUsingApiEntryParameters entry) {
    final severity =
        entry.severity ?? parameters.severity ?? DiagnosticSeverity.INFO;
    final message = entry.reason ?? AvoidUsingApiRule.defaultMessage;

    return LintCode(
      AvoidUsingApiRule.lintName,
      message,
      severity: severity,
      uniqueName: AvoidUsingApiRule.getUniqueName(severity),
    );
  }

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) =>
      _visit(node, super.visitSimpleIdentifier, _checkSimpleIdentifier);

  @override
  void visitNamedType(NamedType node) =>
      _visit(node, super.visitNamedType, _checkNamedType);

  @override
  void visitVariableDeclaration(VariableDeclaration node) =>
      _visit(node, super.visitVariableDeclaration, _checkVariableDeclaration);

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) =>
      _visit(
        node,
        super.visitInstanceCreationExpression,
        _checkInstanceCreation,
      );

  @override
  void visitMethodInvocation(MethodInvocation node) =>
      _visit(node, super.visitMethodInvocation, _checkMethodInvocation);

  void _visit<T>(
    T node,
    void Function(T) visitSuper,
    void Function(
      T,
      AvoidUsingApiEntryParameters,
      void Function(SyntacticEntity),
    )
    visitEntry,
  ) {
    visitSuper(node);

    final resolved = _resolveContext();
    if (resolved == null) return;
    final (:activeEntries, :reporter) = resolved;

    for (final entry in activeEntries) {
      visitEntry(node, entry, (target) {
        if (target is AstNode) {
          reporter.atNode(target, _getLintCode(entry));
        } else if (target is Token) {
          reporter.atToken(target, _getLintCode(entry));
        }
      });
    }
  }

  void _checkSimpleIdentifier(
    SimpleIdentifier node,
    AvoidUsingApiEntryParameters entry,
    void Function(SyntacticEntity) report,
  ) {
    final source = entry.source;
    if (source == null) return;

    switch ((entry.className, entry.identifier, entry.namedParameter)) {
      case (String _, String _, String _):
        // Handled in visitMethodInvocation and
        // visitInstanceCreationExpression
        break;
      case (String _, String _, null):
        _checkIdFromClassFromSource(node, entry, report);
      case (String _, null, null):
        _checkClassFromSource(node, entry, report);
      case (null, String _, null):
        _checkIdFromSource(node, entry, report);
      case (null, null, null):
        _checkSource(node, entry, report);
      default:
        break;
    }
  }

  void _checkClassFromSource(
    SimpleIdentifier node,
    AvoidUsingApiEntryParameters entry,
    void Function(SyntacticEntity) report,
  ) {
    final className = entry.className;
    final source = entry.source;
    final parent = node.parent;
    final element = node.element;
    if (className == null ||
        source == null ||
        parent == null ||
        element == null ||
        parent is ConstructorDeclaration ||
        !element.isMemberOrClass(
          className: className,
          source: source,
        )) {
      return;
    }

    report(node);
  }

  void _checkIdFromClassFromSource(
    SimpleIdentifier node,
    AvoidUsingApiEntryParameters entry,
    void Function(SyntacticEntity) report,
  ) {
    final identifier = entry.identifier;
    final className = entry.className;
    final source = entry.source;
    final parent = node.parent;
    final element = node.element;
    if (identifier == null ||
        className == null ||
        source == null ||
        element == null ||
        identifier == _defaultConstructorIdentifier ||
        node.name != identifier ||
        parent == null ||
        parent is ConstructorDeclaration ||
        !element.isMemberOrClass(
          className: className,
          source: source,
        )) {
      return;
    }

    report(node);
  }

  void _checkSource(
    SimpleIdentifier node,
    AvoidUsingApiEntryParameters entry,
    void Function(SyntacticEntity) report,
  ) {
    final source = entry.source;
    if (source == null ||
        !matchesSource(node.sourceUrl, source) ||
        node.parent is ConstructorDeclaration) {
      return;
    }

    report(node);
  }

  void _checkIdFromSource(
    SimpleIdentifier node,
    AvoidUsingApiEntryParameters entry,
    void Function(SyntacticEntity) report,
  ) {
    final identifier = entry.identifier;
    final source = entry.source;
    if (identifier == null ||
        source == null ||
        node.name != identifier ||
        !matchesSource(node.sourceUrl, source) ||
        node.parent is ConstructorDeclaration) {
      return;
    }

    if (node.element
        case LocalFunctionElement() ||
            TopLevelFunctionElement() ||
            PropertyAccessorElement()) {
      report(node);
    }
  }

  void _checkNamedType(
    NamedType node,
    AvoidUsingApiEntryParameters entry,
    void Function(SyntacticEntity) report,
  ) {
    final source = entry.source;
    if (source == null ||
        entry.identifier != null ||
        !matchesSource(node.sourceUrl, source) ||
        (entry.className != null && node.name.lexeme != entry.className)) {
      return;
    }

    report(node);
  }

  void _checkVariableDeclaration(
    VariableDeclaration node,
    AvoidUsingApiEntryParameters entry,
    void Function(SyntacticEntity) report,
  ) {
    final source = entry.source;
    final className = entry.className;
    final typeElement = node.declaredType?.element;
    if (source == null ||
        entry.identifier != null ||
        className == null ||
        typeElement?.name != className ||
        !matchesSource(typeElement?.libraryUri, source)) {
      return;
    }

    report(node.name);
  }

  void _checkInstanceCreation(
    InstanceCreationExpression node,
    AvoidUsingApiEntryParameters entry,
    void Function(SyntacticEntity) report,
  ) {
    final source = entry.source;
    if (source == null) return;

    final className = entry.className;
    final identifier = entry.identifier;
    final namedParameter = entry.namedParameter;

    switch ((className, identifier, namedParameter)) {
      case (
        final String className,
        final String identifier,
        final String namedParameter,
      ):
        // banUsageWithSpecificNamedParameter
        String? expectedConstructorName;
        if (identifier != _defaultConstructorIdentifier) {
          expectedConstructorName = identifier;
        }

        final actualClassName = node.constructorName.type.name.lexeme;
        if (actualClassName == className &&
            node.constructorName.name?.name == expectedConstructorName &&
            node.argumentList.containsNamed(namedParameter) &&
            matchesSource(
              node.constructorName.type.element?.libraryUri,
              source,
            )) {
          report(node.constructorName.type);
        }

      case (final String className, _defaultConstructorIdentifier, null):
        // banIdFromClassFromSource for default constructor
        final constructorName = node.constructorName.type.name.lexeme;
        if (constructorName == className &&
            node.constructorName.name == null &&
            matchesSource(
              node.constructorName.type.element?.libraryUri,
              source,
            )) {
          report(node.constructorName.type);
        }
      default:
        break;
    }
  }

  void _checkMethodInvocation(
    MethodInvocation node,
    AvoidUsingApiEntryParameters entry,
    void Function(SyntacticEntity) report,
  ) {
    final AvoidUsingApiEntryParameters(:source, :className, :namedParameter) =
        entry;

    final methodName = node.methodName;
    final enclosingElement = methodName.element?.enclosingElement;

    if (source == null ||
        className == null ||
        namedParameter == null ||
        methodName.name != entry.identifier ||
        enclosingElement == null ||
        enclosingElement.name != className ||
        !node.argumentList.containsNamed(namedParameter) ||
        !matchesSource(enclosingElement.libraryUri, source)) {
      return;
    }

    report(methodName);
  }
}
