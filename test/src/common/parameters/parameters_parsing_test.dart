import 'package:solid_lints/src/common/parameters/excluded_annotations_list_parameter.dart';
import 'package:solid_lints/src/common/parameters/excluded_entities_list_parameter.dart';
import 'package:solid_lints/src/common/parameters/excluded_identifiers_list_parameter.dart';
import 'package:test/test.dart';

void main() {
  group('ExcludedAnnotationsListParameter', () {
    test('parses list of strings', () {
      final param = ExcludedAnnotationsListParameter.fromJson({
        'exclude_annotation': ['MyAnnotation1', 'MyAnnotation2'],
      });
      expect(param.excludedAnnotations, containsAll(['MyAnnotation1', 'MyAnnotation2']));
    });

    test('parses single string', () {
      final param = ExcludedAnnotationsListParameter.fromJson({
        'exclude_annotation': 'MyAnnotation',
      });
      expect(param.excludedAnnotations, contains('MyAnnotation'));
      expect(param.excludedAnnotations.length, 1);
    });

    test('parses empty or invalid input', () {
      final param = ExcludedAnnotationsListParameter.fromJson({});
      expect(param.excludedAnnotations, isEmpty);
    });
  });

  group('ExcludedEntitiesListParameter', () {
    test('parses list of strings', () {
      final param = ExcludedEntitiesListParameter.fromJson({
        'exclude_entity': ['mixin', 'enum'],
      });
      expect(param.excludedEntityNames, containsAll(['mixin', 'enum']));
    });

    test('parses single string', () {
      final param = ExcludedEntitiesListParameter.fromJson({
        'exclude_entity': 'mixin',
      });
      expect(param.excludedEntityNames, contains('mixin'));
      expect(param.excludedEntityNames.length, 1);
    });

    test('parses empty or invalid input', () {
      final param = ExcludedEntitiesListParameter.fromJson({});
      expect(param.excludedEntityNames, isEmpty);
    });
  });

  group('ExcludedIdentifiersListParameter', () {
    test('parses list of strings and maps', () {
      final param = ExcludedIdentifiersListParameter.defaultFromJson({
        'exclude': [
          'my_function',
          {'class_name': 'MyClass', 'method_name': 'my_method'},
        ],
      });
      expect(param.exclude.length, 2);
      expect(param.exclude[0].declarationName, 'my_function');
      expect(param.exclude[1].className, 'MyClass');
      expect(param.exclude[1].methodName, 'my_method');
    });

    test('parses single string', () {
      final param = ExcludedIdentifiersListParameter.defaultFromJson({
        'exclude': 'my_function',
      });
      expect(param.exclude.length, 1);
      expect(param.exclude[0].declarationName, 'my_function');
    });

    test('parses single map', () {
      final param = ExcludedIdentifiersListParameter.defaultFromJson({
        'exclude': {'class_name': 'MyClass', 'method_name': 'my_method'},
      });
      expect(param.exclude.length, 1);
      expect(param.exclude[0].className, 'MyClass');
      expect(param.exclude[0].methodName, 'my_method');
    });

    test('parses empty or invalid input', () {
      final param = ExcludedIdentifiersListParameter.defaultFromJson({});
      expect(param.exclude, isEmpty);
    });
  });
}
