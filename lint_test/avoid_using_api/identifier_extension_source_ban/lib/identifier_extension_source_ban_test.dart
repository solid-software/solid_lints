import 'package:external_source/external_source.dart';

void extensionIdentifierBanTesting(){
  const int a = 10;

  // expect_lint: avoid_using_api
  a.banned();
}