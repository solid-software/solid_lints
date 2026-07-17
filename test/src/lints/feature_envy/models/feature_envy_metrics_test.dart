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

    final metrics = FeatureEnvyMetrics.calculate(
      internalAccesses: 1,
      externalAccessCounts: {extA: 2},
    );

    expect(metrics.laa, equals(1 / 3));
    expect(metrics.fdp, equals(1));
    expect(metrics.atfd, equals(2));
    expect(metrics.maxEnvyElement, equals(extA));
  }

  Future<void> test_multiple_external_classes() async {
    final resolved = await _resolveCode('''
class ExternalA {}
class ExternalB {}
''');

    final extA = _getClassElement(resolved, 'ExternalA');
    final extB = _getClassElement(resolved, 'ExternalB');

    final metrics = FeatureEnvyMetrics.calculate(
      internalAccesses: 2,
      externalAccessCounts: {extA: 1, extB: 3},
    );

    expect(metrics.laa, equals(2 / 6));
    expect(metrics.fdp, equals(2));
    expect(metrics.atfd, equals(3));
    expect(metrics.maxEnvyElement, equals(extB));
  }

  Future<void> test_no_accesses_at_all() async {
    final metrics = FeatureEnvyMetrics.calculate(
      internalAccesses: 0,
      externalAccessCounts: const {},
    );

    expect(metrics.laa, equals(1.0));
    expect(metrics.fdp, equals(0));
    expect(metrics.atfd, equals(0));
    expect(metrics.maxEnvyElement, isNull);
  }
}
