import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:yaml/yaml.dart';

/// Checks if parameter name consists only of underscores
bool nameConsistsOfUnderscoresOnly(FormalParameter parameter) {
  final paramName = parameter.name;

  if (paramName == null) return false;

  return paramName.lexeme.replaceAll('_', '').isEmpty;
}

/// Decodes the severity parameter from the string
ErrorSeverity? decodeErrorSeverity(String? severity) {
  return switch (severity) {
    'info' => ErrorSeverity.INFO,
    'warning' => ErrorSeverity.WARNING,
    'error' => ErrorSeverity.ERROR,
    'none' => ErrorSeverity.NONE,
    _ => null,
  };
}

/// Extension to create a copy of [LintCode]
extension LintCodeCopyWith on LintCode {
  /// Returns a copy of [LintCode] with specified fields replaced
  LintCode copyWith({
    String? name,
    String? problemMessage,
    String? correctionMessage,
    String? uniqueName,
    String? url,
    ErrorSeverity? errorSeverity,
  }) =>
      LintCode(
        name: name ?? this.name,
        problemMessage: problemMessage ?? this.problemMessage,
        correctionMessage: correctionMessage ?? this.correctionMessage,
        uniqueName: uniqueName ?? this.uniqueName,
        url: url ?? this.url,
        errorSeverity: errorSeverity ?? this.errorSeverity,
      );
}

/// Source: https://github.com/epam-cross-platform-lab/swagger-dart-code-generator/blob/master/lib/src/extensions/yaml_extensions.dart
extension YamlMapConverter on YamlMap {
  dynamic _convertNode(dynamic v) {
    if (v is YamlMap) {
      return v.toMap();
    } else if (v is YamlList) {
      final list = <dynamic>[];
      for (final e in v) {
        list.add(_convertNode(e));
      }
      return list;
    } else {
      return v;
    }
  }

  /// Converts [YamlMap] to [Map<String, dynamic>]
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    nodes.forEach(
      (k, v) => map[(k as YamlScalar).value.toString()] = _convertNode(v.value),
    );
    return map;
  }
}
