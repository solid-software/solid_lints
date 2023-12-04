import 'package:id_class_ban/src/class_1.dart' as id_class_1;
import 'package:id_class_ban/src/class_2.dart' as id_class_2;

void testingBannedCodeLint() {
  final bannedCodeUsage = id_class_1.BannedCodeUsage();
  // expect_lint: banned_external_code
  bannedCodeUsage.test();

  final bannedCodeUsage2 = id_class_1.BannedCodeUsage.testFactory();
  // expect_lint: banned_external_code
  id_class_1.BannedCodeUsage.testFactory().test();
  // expect_lint: banned_external_code
  bannedCodeUsage2.test();

  final bannedCodeUsage3 = id_class_2.BannedCodeUsage();
  // expect_lint: banned_external_code
  bannedCodeUsage3.test();

  final bannedCodeUsage4 = id_class_2.BannedCodeUsage.testFactory();
  // expect_lint: banned_external_code
  id_class_2.BannedCodeUsage.testFactory().test();
  // expect_lint: banned_external_code
  bannedCodeUsage4.test();
  test();
}

void test() {
  print('Hello World');
}
