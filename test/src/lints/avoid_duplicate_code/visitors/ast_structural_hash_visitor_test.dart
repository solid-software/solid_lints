import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer_testing/src/analysis_rule/pub_package_resolution.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/visitors/ast_structural_hash_visitor.dart';
import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AstStructuralHashVisitorTest);
  });
}

typedef _Hashes = ({int structuralHash, int exactHash});

@reflectiveTest
class AstStructuralHashVisitorTest extends PubPackageResolutionTest {
  Future<void>
  test_named_arguments_do_not_pollute_local_variable_indexing() async {
    final (:fn1, :fn2) = await _computeHashes('''
void foo({required int count, required int delay}) {}

void fn1() {
  final a = 1;
  foo(count: 10, delay: 20);
  final b = 2;
  print(a + b);
}

void fn2() {
  final x = 1;
  foo(count: 10, delay: 20);
  final y = 2;
  print(x + y);
}
''');

    expect(fn1.structuralHash, fn2.structuralHash);
    expect(fn1.exactHash, fn2.exactHash);
  }

  Future<void> test_local_variable_renaming_has_same_structural_hash() async {
    final (:fn1, :fn2) = await _computeHashes('''
int fn1() {
  final a = 10;
  final b = 20;
  return a + b;
}

int fn2() {
  final x = 10;
  final y = 20;
  return x + y;
}
''');

    expect(fn1.structuralHash, fn2.structuralHash);
    expect(fn1.exactHash, fn2.exactHash);
  }

  Future<void>
  test_formal_parameters_renaming_has_same_structural_hash() async {
    final (:fn1, :fn2) = await _computeHashes('''
int fn1(int a, int b) => a + b;
int fn2(int x, int y) => x + y;
''');

    expect(fn1.structuralHash, fn2.structuralHash);
    expect(fn1.exactHash, fn2.exactHash);
  }

  Future<void> test_different_variable_wiring_has_different_hashes() async {
    final (:fn1, :fn2) = await _computeHashes('''
int fn1() {
  final a = 10;
  final b = 20;
  print(a);
  print(b);
  return a - b;
}

int fn2() {
  final a = 10;
  final b = 20;
  print(a);
  print(b);
  return b - a;
}
''');

    expect(fn1.structuralHash, isNot(fn2.structuralHash));
  }

  Future<void>
  test_pattern_variables_renaming_has_same_structural_hash() async {
    final (:fn1, :fn2) = await _computeHashes('''
void fn1((int, int) pair) {
  if (pair case (final a, final b)) {
    print(a + b);
  }
}

void fn2((int, int) pair) {
  if (pair case (final x, final y)) {
    print(x + y);
  }
}
''');

    expect(fn1.structuralHash, fn2.structuralHash);
    expect(fn1.exactHash, fn2.exactHash);
  }

  Future<void>
  test_different_field_or_method_names_have_different_hashes() async {
    final (:fn1, :fn2) = await _computeHashes('''
class User {
  String name = '';
  int age = 0;
  void save() {}
  void delete() {}
}

void fn1(User user) {
  user.save();
  print(user.name);
}

void fn2(User user) {
  user.delete();
  print(user.age);
}
''');

    expect(fn1.structuralHash, isNot(fn2.structuralHash));
  }

  Future<void>
  test_string_literals_have_same_structural_but_different_exact_hash() async {
    final (:fn1, :fn2) = await _computeHashes('''
void fn1() {
  final a = 'hello';
  print(a);
}

void fn2() {
  final a = 'world';
  print(a);
}
''');

    expect(fn1.structuralHash, fn2.structuralHash);
    expect(fn1.exactHash, isNot(fn2.exactHash));
  }

  Future<void>
  test_boolean_literals_have_same_structural_but_different_exact_hash() async {
    final (:fn1, :fn2) = await _computeHashes('''
void fn1() {
  final a = true;
  print(a);
}

void fn2() {
  final a = false;
  print(a);
}
''');

    expect(fn1.structuralHash, fn2.structuralHash);
    expect(fn1.exactHash, isNot(fn2.exactHash));
  }

  Future<void>
  test_symbol_literals_have_same_structural_but_different_exact_hash() async {
    final (:fn1, :fn2) = await _computeHashes('''
void fn1() {
  final a = #foo;
  print(a);
}

void fn2() {
  final a = #bar;
  print(a);
}
''');

    expect(fn1.structuralHash, fn2.structuralHash);
    expect(fn1.exactHash, isNot(fn2.exactHash));
  }

  Future<void>
  test_negative_and_positive_numbers_have_same_structural_hash() async {
    final (:fn1, :fn2) = await _computeHashes('''
void fn1() {
  final a = -5;
  print(a);
}

void fn2() {
  final a = 5;
  print(a);
}
''');

    expect(fn1.structuralHash, fn2.structuralHash);
    expect(fn1.exactHash, isNot(fn2.exactHash));
  }

  Future<void>
  test_different_negative_numbers_have_same_structural_but_different_exact_hash() async {
    final (:fn1, :fn2) = await _computeHashes('''
void fn1() {
  final a = -10.5;
  print(a);
}

void fn2() {
  final a = -20.5;
  print(a);
}
''');

    expect(fn1.structuralHash, fn2.structuralHash);
    expect(fn1.exactHash, isNot(fn2.exactHash));
  }

  Future<void> test_variable_keywords_have_different_structural_hashes() async {
    final (:fn1, :fn2) = await _computeHashes('''
void fn1() {
  final a = 10;
  print(a);
}

void fn2() {
  var a = 10;
  print(a);
}
''');

    expect(fn1.structuralHash, isNot(fn2.structuralHash));
  }

  Future<void>
  test_if_with_else_and_without_else_have_different_structural_hashes() async {
    final (:fn1, :fn2) = await _computeHashes('''
void fn1(bool condition) {
  if (condition) {
    print(1);
  } else {
    print(2);
  }
}

void fn2(bool condition) {
  if (condition) {
    print(1);
  }
  print(2);
}
''');

    expect(fn1.structuralHash, isNot(fn2.structuralHash));
  }

  Future<void>
  test_is_and_is_not_expressions_have_different_structural_hashes() async {
    final (:fn1, :fn2) = await _computeHashes('''
void fn1(Object x) {
  if (x is int) {
    print(x);
  }
}

void fn2(Object x) {
  if (x is! int) {
    print(x);
  }
}
''');

    expect(fn1.structuralHash, isNot(fn2.structuralHash));
  }

  Future<void>
  test_different_binary_operators_have_different_structural_hashes() async {
    final (:fn1, :fn2) = await _computeHashes('''
int fn1(int a, int b) => a + b;
int fn2(int a, int b) => a * b;
''');

    expect(fn1.structuralHash, isNot(fn2.structuralHash));
  }

  Future<({_Hashes fn1, _Hashes fn2})> _computeHashes(
    String source, {
    String fn1Name = 'fn1',
    String fn2Name = 'fn2',
  }) async {
    final file = await _resolveSource(source);
    final declarations = file.unit.declarations
        .whereType<FunctionDeclaration>();
    final fn1 = declarations.firstWhere((d) => d.name.lexeme == fn1Name);
    final fn2 = declarations.firstWhere((d) => d.name.lexeme == fn2Name);

    final hasher = AstStructuralHashVisitor();
    return (
      fn1: hasher.computeHashes(fn1.functionExpression.body),
      fn2: hasher.computeHashes(fn2.functionExpression.body),
    );
  }

  Future<ResolvedUnitResult> _resolveSource(String source) async {
    newFile(testFile.path, source);
    return resolveFile(testFile.path);
  }
}
