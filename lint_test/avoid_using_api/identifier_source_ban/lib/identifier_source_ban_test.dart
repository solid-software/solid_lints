import 'package:external_source/external_source.dart';

void testingBannedCodeLint() {
  final bannedCodeUsage = BannedCodeUsage();
  bannedCodeUsage.test();

  // expect_lint: avoid_using_api
  test();
}
