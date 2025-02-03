// ignore_for_file: prefer_match_file_name, public_member_api_docs
// Check number of parameters fail
///
/// `number_of_parameters: max_parameters`

class UserDto {
  final String a;
  final String b;
  final String c;
  final String d;
  final String e;
  final String f;
  final String g;
  final String h;

  const UserDto({
    required this.a,
    required this.b,
    required this.c,
    required this.d,
    required this.e,
    required this.f,
    required this.g,
    required this.h,
  });

  /// Excluded by method_name
  UserDto copyWith({
    String? a,
    String? b,
    String? c,
    String? d,
    String? e,
    String? f,
    String? g,
    String? h,
  }) {
    return UserDto(
      a: a ?? this.a,
      b: b ?? this.b,
      c: c ?? this.c,
      d: d ?? this.d,
      e: e ?? this.e,
      f: f ?? this.f,
      g: g ?? this.g,
      h: h ?? this.h,
    );
  }

  /// expect_lint: number_of_parameters
  UserDto noCopyWith({
    String? a,
    String? b,
    String? c,
    String? d,
    String? e,
    String? f,
    String? g,
    String? h,
  }) {
    return UserDto(
      a: a ?? this.a,
      b: b ?? this.b,
      c: c ?? this.c,
      d: d ?? this.d,
      e: e ?? this.e,
      f: f ?? this.f,
      g: g ?? this.g,
      h: h ?? this.h,
    );
  }

  /// Allow
  UserDto noLongCopyWith({
    String? a,
    String? b,
    String? c,
  }) {
    return UserDto(
      a: a ?? this.a,
      b: b ?? this.b,
      c: c ?? this.c,
      d: '',
      e: '',
      f: '',
      g: '',
      h: '',
    );
  }
}
