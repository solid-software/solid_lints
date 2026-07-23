import 'package:analyzer/dart/element/element.dart';
import 'package:solid_lints/src/utils/node_utils.dart';

/// A cache for checking if an [InterfaceElement] belongs to the analyzed
/// project.
class ProjectClassCache {
  final _cache = <InterfaceElement, bool>{};

  /// Returns `true` if [element] belongs to the analyzed project.
  /// Results are cached for better performance during static analysis.
  bool isProjectClass(InterfaceElement element) =>
      _cache.putIfAbsent(element, () => element.isFromProject);
}
