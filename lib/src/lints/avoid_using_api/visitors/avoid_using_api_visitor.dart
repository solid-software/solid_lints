import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/dart/ast/ast.dart';
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
  void visitSimpleIdentifier(SimpleIdentifier node) {
    super.visitSimpleIdentifier(node);

    final resolved = _resolveContext();
    if (resolved == null) return;
    final (:activeEntries, :reporter) = resolved;

    for (final entry in activeEntries) {
      final source = entry.source;
      if (source == null) continue;

      switch ((entry.className, entry.identifier, entry.namedParameter)) {
        case (String _, String _, String _):
          // Handled in visitMethodInvocation and
          // visitInstanceCreationExpression
          continue;
        case (String _, String _, null):
          _checkIdFromClassFromSource(node, entry, reporter);
        case (String _, null, null):
          _checkClassFromSource(node, entry, reporter);
        case (null, String _, null):
          _checkIdFromSource(node, entry, reporter);
        case (null, null, null):
          _checkSource(node, entry, reporter);
        default:
          break;
      }
    }
  }

  @override
  void visitNamedType(NamedType node) {
    super.visitNamedType(node);

    final resolved = _resolveContext();
    if (resolved == null) return;
    final (:activeEntries, :reporter) = resolved;

    for (final entry in activeEntries) {
      _checkNamedType(node, entry, reporter);
    }
  }

  @override
  void visitVariableDeclaration(VariableDeclaration node) {
    super.visitVariableDeclaration(node);

    final resolved = _resolveContext();
    if (resolved == null) return;
    final (:activeEntries, :reporter) = resolved;

    for (final entry in activeEntries) {
      _checkVariableDeclaration(node, entry, reporter);
    }
  }

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    super.visitInstanceCreationExpression(node);

    final resolved = _resolveContext();
    if (resolved == null) return;
    final (:activeEntries, :reporter) = resolved;

    for (final entry in activeEntries) {
      _checkInstanceCreation(node, entry, reporter);
    }
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    super.visitMethodInvocation(node);

    final resolved = _resolveContext();
    if (resolved == null) return;
    final (:activeEntries, :reporter) = resolved;

    for (final entry in activeEntries) {
      _checkMethodInvocation(node, entry, reporter);
    }
  }

  void _checkClassFromSource(
    SimpleIdentifier node,
    AvoidUsingApiEntryParameters entry,
    DiagnosticReporter reporter,
  ) {
    final className = entry.className;
    final source = entry.source;
    final parent = node.parent;
    if (className == null ||
        source == null ||
        parent == null ||
        parent is ConstructorDeclaration ||
        !_isMemberOrClass(node.element, className, source)) {
      return;
    }

    reporter.atNode(node, _getLintCode(entry));
  }

  void _checkIdFromClassFromSource(
    SimpleIdentifier node,
    AvoidUsingApiEntryParameters entry,
    DiagnosticReporter reporter,
  ) {
    final identifier = entry.identifier;
    final className = entry.className;
    final source = entry.source;
    final parent = node.parent;
    if (identifier == null ||
        className == null ||
        source == null ||
        identifier == _defaultConstructorIdentifier ||
        node.name != identifier ||
        parent == null ||
        parent is ConstructorDeclaration ||
        !_isMemberOrClass(node.element, className, source)) {
      return;
    }

    reporter.atNode(node, _getLintCode(entry));
  }

  void _checkSource(
    SimpleIdentifier node,
    AvoidUsingApiEntryParameters entry,
    DiagnosticReporter reporter,
  ) {
    final source = entry.source;
    if (source == null ||
        !matchesSource(node.sourceUrl, source) ||
        node.parent is ConstructorDeclaration) {
      return;
    }

    reporter.atNode(node, _getLintCode(entry));
  }

  void _checkIdFromSource(
    SimpleIdentifier node,
    AvoidUsingApiEntryParameters entry,
    DiagnosticReporter reporter,
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
      reporter.atNode(node, _getLintCode(entry));
    }
  }

  void _checkNamedType(
    NamedType node,
    AvoidUsingApiEntryParameters entry,
    DiagnosticReporter reporter,
  ) {
    final source = entry.source;
    if (source == null ||
        entry.identifier != null ||
        !matchesSource(node.sourceUrl, source) ||
        (entry.className != null && node.name.lexeme != entry.className)) {
      return;
    }

    reporter.atNode(node, _getLintCode(entry));
  }

  void _checkVariableDeclaration(
    VariableDeclaration node,
    AvoidUsingApiEntryParameters entry,
    DiagnosticReporter reporter,
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

    reporter.atOffset(
      offset: node.name.offset,
      length: node.name.length,
      diagnosticCode: _getLintCode(entry),
    );
  }

  void _checkInstanceCreation(
    InstanceCreationExpression node,
    AvoidUsingApiEntryParameters entry,
    DiagnosticReporter reporter,
  ) {
    final source = entry.source;
    final className = entry.className;
    if (source == null ||
        className == null ||
        node.constructorName.type.name.lexeme != className ||
        !matchesSource(
          node.constructorName.type.element?.libraryUri,
          source,
        )) {
      return;
    }

    final identifier = entry.identifier;
    final namedParameter = entry.namedParameter;

    // Case 1: banUsageWithSpecificNamedParameter
    if (identifier != null && namedParameter != null) {
      final expectedConstructorName =
          identifier != _defaultConstructorIdentifier ? identifier : null;
      if (node.constructorName.name?.name == expectedConstructorName &&
          node.argumentList.containsNamed(namedParameter)) {
        reporter.atNode(node.constructorName.type, _getLintCode(entry));
      }
    }
    // Case 2: banIdFromClassFromSource for default constructor
    else if (identifier == _defaultConstructorIdentifier &&
        namedParameter == null) {
      if (node.constructorName.name == null) {
        reporter.atNode(node.constructorName.type, _getLintCode(entry));
      }
    }
  }

  void _checkMethodInvocation(
    MethodInvocation node,
    AvoidUsingApiEntryParameters entry,
    DiagnosticReporter reporter,
  ) {
    final source = entry.source;
    final className = entry.className;
    final namedParameter = entry.namedParameter;
    if (source == null ||
        className == null ||
        namedParameter == null ||
        node.methodName.name != entry.identifier) {
      return;
    }

    final enclosingElement = node.methodName.element?.enclosingElement;
    if (enclosingElement != null &&
        enclosingElement.name == className &&
        node.argumentList.containsNamed(namedParameter) &&
        matchesSource(enclosingElement.libraryUri, source)) {
      reporter.atNode(node.methodName, _getLintCode(entry));
    }
  }

  bool _isMemberOrClass(Element? element, String className, String source) {
    final target = element is InterfaceElement
        ? element
        : element?.enclosingElement;

    if (target case InterfaceElement() || ExtensionElement()
        when target != null) {
      return target.name == className &&
          matchesSource(target.libraryUri, source);
    }

    return false;
  }
}
