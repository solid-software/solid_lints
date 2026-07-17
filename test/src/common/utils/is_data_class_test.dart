import 'package:analyzer/dart/analysis/results.dart';
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
  Future<ResolvedUnitResult> _resolveCode(String code) async {
    newFile(testFile.path, code);
    return resolveFile(testFile.path);
  }

  Future<void> test_isDataClass_for_pure_data_class() async {
    final resolved = await _resolveCode('''
class Rectangle {
  final int width;
  final int height;
  const Rectangle(this.width, this.height);
}
''');
    final classDecl = resolved.unit.declarations
        .whereType<ClassDeclaration>()
        .first;
    final element = classDecl.declaredFragment?.element;
    expect(element, isNotNull);

    expect(element?.isDataClass, isTrue);
  }

  Future<void> test_isDataClass_for_non_data_class() async {
    final resolved = await _resolveCode('''
class Rectangle {
  final int width;
  final int height;
  const Rectangle(this.width, this.height);
  int area() => width * height;
  void printMe() {}
}
''');
    final classDecl = resolved.unit.declarations
        .whereType<ClassDeclaration>()
        .first;
    final element = classDecl.declaredFragment?.element;
    expect(element, isNotNull);

    expect(element?.isDataClass, isFalse);
  }

  Future<void> test_isDataClass_collision_case() async {
    final resolved = await _resolveCode('''
class Base {
  int get foo => 42;
}

class Sub extends Base {
  @override
  int foo() => 42;
}
''');
    final subDecl = resolved.unit.declarations
        .whereType<ClassDeclaration>()
        .firstWhere((d) => d.namePart.typeName.lexeme == 'Sub');
    final element = subDecl.declaredFragment?.element;
    expect(element, isNotNull);

    expect(element?.isDataClass, isFalse);
  }
}
