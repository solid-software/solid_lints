import 'package:named_parameter_ban/named_parameter_ban.dart';

void testingBannedCodeLint() async {
  // expect_lint: avoid_using_api
  NamedParameterBan(badParameter: '');
  NamedParameterBan(goodParameter: '');

  // expect_lint: avoid_using_api
  NamedParameterBan.namedConstructor(badParameter: '');
  NamedParameterBan.namedConstructor(goodParameter: '');

  // expect_lint: avoid_using_api
  NamedParameterBan.staticMethod(
    badParameter: 'test',
  );
  NamedParameterBan.staticMethod(goodParameter: '');

  final obj = NamedParameterBan();
  // expect_lint: avoid_using_api
  obj.method(badParameter: '');
  obj.method(goodParameter: '');

  // expect_lint: avoid_using_api
  0.extensionMethod(badParameter: '');
  0.extensionMethod(goodParameter: '');
}
