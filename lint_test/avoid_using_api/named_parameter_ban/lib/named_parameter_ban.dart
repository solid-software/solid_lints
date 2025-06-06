class NamedParameterBan {
  NamedParameterBan({this.badParameter, this.goodParameter});

  String? badParameter;
  String? goodParameter;

  NamedParameterBan.namedConstructor(
      {String? badParameter, String? goodParameter}) {}

  void method({String? badParameter, String? goodParameter}) {}
  static void staticMethod({String? badParameter, String? goodParameter}) {}
}

extension NamedParameterBanExtension on int {
  String extensionMethod({String? badParameter, String? goodParameter}) => '';
}
