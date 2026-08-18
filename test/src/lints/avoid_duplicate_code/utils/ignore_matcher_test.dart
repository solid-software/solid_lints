import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/utils/ignore_matcher.dart';
import 'package:test/test.dart';

void main() {
  group('IgnoreMatcher', () {
    group('isFileIgnored', () {
      test('returns true for // ignore_for_file: avoid_duplicate_code', () {
        final result = parseString(
          content: '''
// ignore_for_file: avoid_duplicate_code

void foo() {}
''',
        );

        expect(IgnoreMatcher.isFileIgnored(result.unit), isTrue);
      });

      test(
        'returns true for // ignore_for_file: solid_lints/avoid_duplicate_code',
        () {
          final result = parseString(
            content: '''
// ignore_for_file: solid_lints/avoid_duplicate_code

void foo() {}
''',
          );

          expect(IgnoreMatcher.isFileIgnored(result.unit), isTrue);
        },
      );

      test('returns true when combined with other rules', () {
        final result = parseString(
          content: '''
// ignore_for_file: other_rule, avoid_duplicate_code, another_rule

void foo() {}
''',
        );

        expect(IgnoreMatcher.isFileIgnored(result.unit), isTrue);
      });

      test('returns true when placed between directives', () {
        final result = parseString(
          content: '''
import 'dart:async';

// ignore_for_file: avoid_duplicate_code
import 'dart:io';

void foo() {}
''',
        );

        expect(IgnoreMatcher.isFileIgnored(result.unit), isTrue);
      });

      test('returns false when no ignore comments present', () {
        final result = parseString(
          content: '''
void foo() {}
''',
        );

        expect(IgnoreMatcher.isFileIgnored(result.unit), isFalse);
      });

      test('returns false for unrelated rule ignore_for_file', () {
        final result = parseString(
          content: '''
// ignore_for_file: other_rule

void foo() {}
''',
        );

        expect(IgnoreMatcher.isFileIgnored(result.unit), isFalse);
      });
    });

    group('isCandidateIgnored', () {
      test('returns true for // ignore: avoid_duplicate_code on function', () {
        final (body, decl) = _parseFunction('''
// ignore: avoid_duplicate_code
void foo() {
  final x = 1;
}
''');

        expect(IgnoreMatcher.isCandidateIgnored(body, decl), isTrue);
      });

      test('returns true for // ignore: solid_lints/avoid_duplicate_code', () {
        final (body, decl) = _parseFunction('''
// ignore: solid_lints/avoid_duplicate_code
void foo() {
  final x = 1;
}
''');

        expect(IgnoreMatcher.isCandidateIgnored(body, decl), isTrue);
      });

      test('returns true when ignore is placed after @override annotation', () {
        final result = parseString(
          content: '''
class Foo {
  @override
  // ignore: avoid_duplicate_code
  void foo() {
    final x = 1;
  }
}
''',
        );

        final classDecl = result.unit.declarations.first as ClassDeclaration;
        final methodDecl = switch (classDecl.body) {
          BlockClassBody(:final members) => members.first as MethodDeclaration,
          _ => throw StateError('Expected BlockClassBody'),
        };
        final body = (methodDecl.body as BlockFunctionBody).block;

        expect(IgnoreMatcher.isCandidateIgnored(body, methodDecl), isTrue);
      });

      test(
        'returns true for inline ignore directly on block without declaration',
        () {
          final result = parseString(
            content: '''
void foo() {
  // ignore: avoid_duplicate_code
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

          expect(IgnoreMatcher.isCandidateIgnored(innerBlock, null), isTrue);
        },
      );

      test('returns false when method is not ignored', () {
        final (body, decl) = _parseFunction('''
void foo() {
  final x = 1;
}
''');

        expect(IgnoreMatcher.isCandidateIgnored(body, decl), isFalse);
      });

      test('returns false when another rule is ignored', () {
        final (body, decl) = _parseFunction('''
// ignore: other_rule
void foo() {
  final x = 1;
}
''');

        expect(IgnoreMatcher.isCandidateIgnored(body, decl), isFalse);
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
