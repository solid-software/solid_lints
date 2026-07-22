import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer_testing/src/analysis_rule/pub_package_resolution.dart';
import 'package:solid_lints/src/lints/feature_envy/models/feature_envy_metrics.dart';
import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(FeatureEnvyMetricsTest);
  });
}

@reflectiveTest
class FeatureEnvyMetricsTest extends PubPackageResolutionTest {
  Future<ResolvedUnitResult> _resolveCode(String code) {
    newFile(testFile.path, code);
    return resolveFile(testFile.path);
  }

  ClassElement _getClassElement(ResolvedUnitResult result, String className) {
    final declaration = result.unit.declarations
        .whereType<ClassDeclaration>()
        .firstWhere((d) => d.namePart.typeName.lexeme == className);
    return declaration.declaredFragment!.element;
  }

  Future<void> test_standard_calculations() async {
    final resolved = await _resolveCode('''
class ExternalA {}
''');

    final extA = _getClassElement(resolved, 'ExternalA');

    _expectMetrics(
      internalAccesses: 1,
      externalAccessCounts: {extA: 2},
      laa: 1 / 3,
      fdp: 1,
      atfd: 2,
      maxEnvyElement: extA,
    );
  }

  Future<void> test_multiple_external_classes() async {
    final resolved = await _resolveCode('''
class ExternalA {}
class ExternalB {}
''');

    final extA = _getClassElement(resolved, 'ExternalA');
    final extB = _getClassElement(resolved, 'ExternalB');

    _expectMetrics(
      internalAccesses: 2,
      externalAccessCounts: {extA: 1, extB: 3},
      laa: 2 / 6,
      fdp: 2,
      atfd: 3,
      maxEnvyElement: extB,
    );
  }

  Future<void> test_no_accesses_at_all() async {
    _expectMetrics(
      internalAccesses: 0,
      externalAccessCounts: const {},
      laa: 1.0,
      fdp: 0,
      atfd: 0,
      maxEnvyElement: null,
    );
  }

  void _expectMetrics({
    required int internalAccesses,
    required Map<InterfaceElement, int> externalAccessCounts,
    required double laa,
    required int fdp,
    required int atfd,
    required InterfaceElement? maxEnvyElement,
  }) {
    final metrics = FeatureEnvyMetrics.calculate(
      internalAccesses: internalAccesses,
      externalAccessCounts: externalAccessCounts,
    );

    expect(metrics.laa, equals(laa));
    expect(metrics.fdp, equals(fdp));
    expect(metrics.atfd, equals(atfd));
    expect(metrics.maxEnvyElement, equals(maxEnvyElement));
  }
}
