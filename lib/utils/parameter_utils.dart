import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

/// Checks if parameter name consists only of underscores
bool nameConsistsOfUnderscoresOnly(FormalParameter parameter) {
  final paramName = parameter.name;

  if (paramName == null) return false;

  return paramName.lexeme.replaceAll('_', '').isEmpty;
}

/// Decodes the severity parameter from the string
ErrorSeverity? decodeErrorSeverity(String? severity) {
  return switch (severity?.toLowerCase()) {
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

/// Determines whether the file should be skipped using Glob patterns
///
/// See https://pub.dev/packages/glob
bool shouldSkipFile({
  required List<String> includeGlobs,
  required List<String> excludeGlobs,
  required String path,
  String? rootPath,
}) {
  if (includeGlobs.isEmpty && excludeGlobs.isEmpty) {
    return false;
  }

  final bool isIncludeOnly = excludeGlobs.isEmpty && includeGlobs.isNotEmpty;
  final bool isExcludeOnly = includeGlobs.isEmpty && excludeGlobs.isNotEmpty;
  final pathNormalized = normalizePath(
    path,
    rootPath != null ? normalizePath(rootPath) : null,
  );
  if (isIncludeOnly) {
    return _isFileNotIncluded(includeGlobs, path);
  }

  if (isExcludeOnly) {
    return _isFileExcluded(includeGlobs, pathNormalized);
  }

  final isFileNotIncluded = _isFileNotIncluded(includeGlobs, pathNormalized);
  final isFileExcluded = _isFileExcluded(excludeGlobs, pathNormalized);
  return isFileNotIncluded || isFileExcluded;
}

bool _isFileExcluded(List<String> excludes, String path) {
  final hasMatch =
      excludes.map(Glob.new).toList().any((glob) => glob.matches(path));
  return hasMatch;
}

bool _isFileIncluded(List<String> includes, String path) {
  final hasMatch =
      includes.map(Glob.new).toList().any((glob) => glob.matches(path));
  return hasMatch;
}

bool _isFileNotIncluded(List<String> includes, String path) {
  return !_isFileIncluded(includes, path);
}

/// Normalizes the path using posix style and
/// replaces backslashes with forward slashes
String normalizePath(String path, [String? root]) {
  // Remove drive letter from path
  final String subpath = _removeDriveLetter(path);

  return p.posix.relative(subpath.replaceAll(r'\', '/'), from: root);
}

String _removeDriveLetter(String path) {
  if (p.context.style != p.Style.windows) {
    return path;
  }

  if (path.contains(":")) {
    final indexOfColon = path.indexOf(':');
    if (indexOfColon == 1 && indexOfColon < path.length - 1) {
      return path.substring(indexOfColon + 1);
    }
  }

  return path;
}
