// ignore_for_file: unused_local_variable

import 'package:external_source/external_source.dart';

void testingBannedCodeLint() async {
  // expect_lint: avoid_using_api
  final bannedCodeUsage = BannedCodeUsage(parameter1: '');

  // expect_lint: avoid_using_api
  final test3 = BannedCodeUsage.test3(parameter1: '');

  // expect_lint: avoid_using_api
  final test5 = BannedCodeUsage.test5(parameter1: '');

  // expect_lint: avoid_using_api
  BannedCodeUsage.test2(
    parameter1: 'test',
  );

  final obj = BannedCodeUsage();
  // expect_lint: avoid_using_api
  obj.test(parameter1: '');

  test(parameter1: '');

  // expect_lint: avoid_using_api
  2.banned(parameter1: '');
}
