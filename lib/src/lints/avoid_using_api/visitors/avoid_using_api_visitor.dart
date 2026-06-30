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

  List<AvoidUsingApiEntryParameters>? _cachedActiveEntries;

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

  LintCode _getLintCode(AvoidUsingApiEntryParameters entry) => LintCode(
    AvoidUsingApiRule.lintName,
    entry.reason ?? AvoidUsingApiRule.defaultMessage,
    severity: entry.severity ?? parameters.severity ?? DiagnosticSeverity.INFO,
  );

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
    if (className == null || source == null) {
      return;
    }

    final parent = node.parent;
    if (parent == null || parent is ConstructorDeclaration) {
      return;
    }

    if (_isMemberOrClass(node.element, className, source)) {
      reporter.atNode(node, _getLintCode(entry));
    }
  }

  void _checkIdFromClassFromSource(
    SimpleIdentifier node,
    AvoidUsingApiEntryParameters entry,
    DiagnosticReporter reporter,
  ) {
    final identifier = entry.identifier;
    final className = entry.className;
    final source = entry.source;
    if (identifier == null || className == null || source == null) {
      return;
    }

    if (identifier == _defaultConstructorIdentifier ||
        node.name != identifier) {
      return;
    }

    final parent = node.parent;
    if (parent == null || parent is ConstructorDeclaration) {
      return;
    }

    if (_isMemberOrClass(node.element, className, source)) {
      reporter.atNode(node, _getLintCode(entry));
    }
  }

  void _checkSource(
    SimpleIdentifier node,
    AvoidUsingApiEntryParameters entry,
    DiagnosticReporter reporter,
  ) {
    final source = entry.source;
    if (source == null || !matchesSource(node.sourceUrl, source)) {
      return;
    }

    if (node.parent is ConstructorDeclaration) {
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
    if (identifier == null || source == null) {
      return;
    }

    if (node.name != identifier) {
      return;
    }

    if (!matchesSource(node.sourceUrl, source)) {
      return;
    }

    if (node.parent is ConstructorDeclaration) {
      return;
    }

    final element = node.element;
    if (element is LocalFunctionElement ||
        element is TopLevelFunctionElement ||
        element is PropertyAccessorElement) {
      reporter.atNode(node, _getLintCode(entry));
    }
  }

  void _checkNamedType(
    NamedType node,
    AvoidUsingApiEntryParameters entry,
    DiagnosticReporter reporter,
  ) {
    final source = entry.source;
    if (source == null) return;

    final className = entry.className;
    final identifier = entry.identifier;

    switch ((className, identifier)) {
      case (null, null):
        // banSource
        if (matchesSource(node.sourceUrl, source)) {
          reporter.atNode(node, _getLintCode(entry));
        }
      case (final String className, null):
        // banClassFromSource
        if (node.name.lexeme == className &&
            matchesSource(node.sourceUrl, source)) {
          reporter.atNode(node, _getLintCode(entry));
        }
      default:
        break;
    }
  }

  void _checkVariableDeclaration(
    VariableDeclaration node,
    AvoidUsingApiEntryParameters entry,
    DiagnosticReporter reporter,
  ) {
    final source = entry.source;
    if (source == null) return;

    final className = entry.className;

    switch ((className, entry.identifier)) {
      case (final String className, null):
        // banClassFromSource
        final typeElement = node.declaredType?.element;
        if (typeElement?.name == className &&
            matchesSource(typeElement?.libraryUri, source)) {
          reporter.atOffset(
            offset: node.name.offset,
            length: node.name.length,
            diagnosticCode: _getLintCode(entry),
          );
        }
      default:
        break;
    }
  }

  void _checkInstanceCreation(
    InstanceCreationExpression node,
    AvoidUsingApiEntryParameters entry,
    DiagnosticReporter reporter,
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
        if (actualClassName != className) {
          return;
        }

        if (node.constructorName.name?.name != expectedConstructorName) {
          return;
        }

        if (!node.argumentList.containsNamed(namedParameter)) {
          return;
        }

        if (matchesSource(
          node.constructorName.type.element?.libraryUri,
          source,
        )) {
          reporter.atNode(node.constructorName.type, _getLintCode(entry));
        }

      case (final String className, _defaultConstructorIdentifier, null):
        // banIdFromClassFromSource for default constructor
        final constructorName = node.constructorName.type.name.lexeme;
        if (constructorName != className || node.constructorName.name != null) {
          return;
        }

        if (matchesSource(
          node.constructorName.type.element?.libraryUri,
          source,
        )) {
          reporter.atNode(node.constructorName.type, _getLintCode(entry));
        }
      default:
        break;
    }
  }

  void _checkMethodInvocation(
    MethodInvocation node,
    AvoidUsingApiEntryParameters entry,
    DiagnosticReporter reporter,
  ) {
    final source = entry.source;
    if (source == null) return;

    final className = entry.className;
    final identifier = entry.identifier;
    final namedParameter = entry.namedParameter;

    final methodName = node.methodName.name;
    if (methodName != identifier) return;

    switch ((className, identifier, namedParameter)) {
      case (final String className, String _, final String namedParameter):
        // banUsageWithSpecificNamedParameter
        final enclosingElement = node.methodName.element?.enclosingElement;
        if (enclosingElement == null || enclosingElement.name != className) {
          return;
        }

        if (!node.argumentList.containsNamed(namedParameter)) {
          return;
        }

        if (matchesSource(enclosingElement.libraryUri, source)) {
          reporter.atNode(node.methodName, _getLintCode(entry));
        }
      default:
        break;
    }
  }

  bool _isMemberOrClass(Element? element, String className, String source) {
    if (element == null) return false;

    final target = element is InterfaceElement
        ? element
        : element.enclosingElement;
    if (target == null) return false;

    if (target is InterfaceElement || target is ExtensionElement) {
      return target.name == className &&
          matchesSource(target.libraryUri, source);
    }

    return false;
  }
}
