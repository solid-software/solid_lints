import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer_testing/src/analysis_rule/pub_package_resolution.dart';
import 'package:solid_lints/src/utils/types_utils.dart';
import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(IsDataClassTest);
  });
}

@reflectiveTest
class IsDataClassTest extends PubPackageResolutionTest {
  Future<void> test_isDataClass_for_pure_data_class() async => _test('''
class Rectangle {
  final int width;
  final int height;
  const Rectangle(this.width, this.height);
}
''', isTrue);

  Future<void> test_isDataClass_for_non_data_class() async => _test('''
class Rectangle {
  final int width;
  final int height;
  const Rectangle(this.width, this.height);
  int area() => width * height;
  void printMe() {}
}
''', isFalse);

  Future<void> test_isDataClass_collision_case() async => _test(
    '''
class Base {
  int get foo => 42;
}

class Sub extends Base {
  @override
  int foo() => 42;
}
''',
    isFalse,
    (d) => d.namePart.typeName.lexeme == 'Sub',
  );

  Future<void> _test(
    String source,
    dynamic matcher, [
    bool Function(ClassDeclaration)? test,
  ]) async {
    newFile(testFile.path, source);
    final file = await resolveFile(testFile.path);

    expect(
      file.unit.declarations
          .whereType<ClassDeclaration>()
          .firstWhere(test ?? (_) => true)
          .declaredFragment
          ?.element
          .isDataClass,
      matcher,
    );
  }
}
