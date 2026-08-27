import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:solid_lints/src/utils/ignore_matcher.dart';
import 'package:test/test.dart';

void main() {
  group('IgnoreMatcher', () {
    const ruleName = 'my_rule';
    final matcher = IgnoreMatcher(ruleName);

    group('isFileIgnored', () {
      test('returns true for simple ignore_for_file comment', () {
        final result = parseString(
          content:
              '''
// ignore_for_file: $ruleName

void foo() {}
''',
        );

        expect(matcher.isFileIgnored(result.unit), isTrue);
      });

      test('returns true for package-prefixed ignore_for_file comment', () {
        final result = parseString(
          content:
              '''
// ignore_for_file: solid_lints/$ruleName

void foo() {}
''',
        );

        expect(matcher.isFileIgnored(result.unit), isTrue);
      });

      test('returns true when combined with other ignored rules', () {
        final result = parseString(
          content:
              '''
// ignore_for_file: other_rule, $ruleName, another_rule

void foo() {}
''',
        );

        expect(matcher.isFileIgnored(result.unit), isTrue);
      });

      test(
        'returns true when combined with other rules and package prefix',
        () {
          final result = parseString(
            content:
                '''
// ignore_for_file: other_rule, solid_lints/$ruleName, another_rule

void foo() {}
''',
          );

          expect(matcher.isFileIgnored(result.unit), isTrue);
        },
      );

      test('returns true when placed between directives', () {
        final result = parseString(
          content:
              '''
import 'dart:async';

// ignore_for_file: $ruleName
import 'dart:io';

void foo() {}
''',
        );

        expect(matcher.isFileIgnored(result.unit), isTrue);
      });

      test(
        'returns true when placed after directives and before declarations',
        () {
          final result = parseString(
            content:
                '''
import 'dart:async';

// ignore_for_file: $ruleName
void foo() {}
''',
          );

          expect(matcher.isFileIgnored(result.unit), isTrue);
        },
      );

      test('returns true when placed at the end of the file', () {
        final result = parseString(
          content:
              '''
void foo() {}

// ignore_for_file: $ruleName
''',
        );

        expect(matcher.isFileIgnored(result.unit), isTrue);
      });

      test('returns false when no ignore comments are present', () {
        final result = parseString(
          content: '''
void foo() {}
''',
        );

        expect(matcher.isFileIgnored(result.unit), isFalse);
      });

      test('returns false for unrelated rule ignore_for_file comment', () {
        final result = parseString(
          content: '''
// ignore_for_file: other_rule

void foo() {}
''',
        );

        expect(matcher.isFileIgnored(result.unit), isFalse);
      });

      test('works with different custom rule names', () {
        const customRule = 'another_custom_rule';
        final customMatcher = IgnoreMatcher(customRule);
        final result = parseString(
          content:
              '''
// ignore_for_file: $customRule

void foo() {}
''',
        );

        expect(customMatcher.isFileIgnored(result.unit), isTrue);
        expect(matcher.isFileIgnored(result.unit), isFalse);
      });
    });

    group('isCandidateIgnored', () {
      test('returns true for inline ignore on function declaration', () {
        final (body, decl) = _parseFunction('''
// ignore: $ruleName
void foo() {
  final x = 1;
}
''');

        expect(matcher.isCandidateIgnored(body, decl), isTrue);
      });

      test('returns true for package-prefixed inline ignore', () {
        final (body, decl) = _parseFunction('''
// ignore: solid_lints/$ruleName
void foo() {
  final x = 1;
}
''');

        expect(matcher.isCandidateIgnored(body, decl), isTrue);
      });

      test(
        'returns true when combined with other rules and package prefix',
        () {
          final (body, decl) = _parseFunction('''
// ignore: other_rule, solid_lints/$ruleName, another_rule
void foo() {
  final x = 1;
}
''');

          expect(matcher.isCandidateIgnored(body, decl), isTrue);
        },
      );

      test(
        'returns true when comments explain ignores across multiple lines',
        () {
          final (body, decl) = _parseFunction('''
// $ruleName is ignored because reasons
// ignore: $ruleName
// other_rule is ignored because reasons
// ignore: other_rule
void foo() {
  final x = 1;
}
''');

          expect(matcher.isCandidateIgnored(body, decl), isTrue);
        },
      );

      test(
        'returns true when inline ignore is placed after metadata annotation',
        () {
          final result = parseString(
            content:
                '''
class Foo {
  @override
  // ignore: $ruleName
  void foo() {
    final x = 1;
  }
}
''',
          );

          final classDecl = result.unit.declarations.first as ClassDeclaration;
          final methodDecl = switch (classDecl.body) {
            BlockClassBody(:final members) =>
              members.first as MethodDeclaration,
            _ => throw StateError('Expected BlockClassBody'),
          };
          final body = (methodDecl.body as BlockFunctionBody).block;

          expect(matcher.isCandidateIgnored(body, methodDecl), isTrue);
        },
      );

      test('returns true for inline ignore directly on statement block', () {
        final result = parseString(
          content:
              '''
void foo() {
  // ignore: $ruleName
  {
    final x = 1;
  }
}
''',
        );

        final decl = result.unit.declarations.first as FunctionDeclaration;
        final outerBody =
            (decl.functionExpression.body as BlockFunctionBody).block;
        final innerBlock = outerBody.statements.first as Block;

        expect(matcher.isCandidateIgnored(innerBlock, null), isTrue);
      });

      test(
        'returns true when inline ignore is placed inside parameter list',
        () {
          final (body, decl) = _parseFunction('''
void foo(
  int a,
  // ignore: $ruleName
  int b,
) {
  final x = 1;
}
''');

          expect(matcher.isCandidateIgnored(body, decl), isTrue);
        },
      );

      test(
        'returns true when inline ignore is placed before closing parenthesis',
        () {
          final (body, decl) = _parseFunction('''
void foo(
  int a,
  int b,
  // ignore: $ruleName
) {
  final x = 1;
}
''');

          expect(matcher.isCandidateIgnored(body, decl), isTrue);
        },
      );

      test(
        'returns true when package-prefixed inline ignore is placed before closing parenthesis',
        () {
          final (body, decl) = _parseFunction('''
void foo(
  int a,
  int b,
  // ignore: solid_lints/$ruleName
) {
  final x = 1;
}
''');

          expect(matcher.isCandidateIgnored(body, decl), isTrue);
        },
      );

      test(
        'returns true for method inside class with ignore in parameters',
        () {
          final result = parseString(
            content:
                '''
abstract class Foo {
  static void bar(
    int a,
    int b,
    // ignore: solid_lints/$ruleName
  ) {
    final x = 1;
  }
}
''',
          );
          final classDecl = result.unit.declarations.first as ClassDeclaration;
          final methodDecl = switch (classDecl.body) {
            BlockClassBody(:final members) =>
              members.first as MethodDeclaration,
            _ => throw StateError('Expected BlockClassBody'),
          };
          final body = (methodDecl.body as BlockFunctionBody).block;
          expect(matcher.isCandidateIgnored(body, methodDecl), isTrue);
        },
      );

      test('returns false when declaration is not ignored', () {
        final (body, decl) = _parseFunction('''
void foo() {
  final x = 1;
}
''');

        expect(matcher.isCandidateIgnored(body, decl), isFalse);
      });

      test('returns false when another unrelated rule is ignored', () {
        final (body, decl) = _parseFunction('''
// ignore: other_rule
void foo() {
  final x = 1;
}
''');

        expect(matcher.isCandidateIgnored(body, decl), isFalse);
      });
    });
  });
}

(Block body, FunctionDeclaration decl) _parseFunction(String content) {
  final unit = parseString(content: content).unit;
  final decl = unit.declarations.first as FunctionDeclaration;
  final body = (decl.functionExpression.body as BlockFunctionBody).block;
  return (body, decl);
}
