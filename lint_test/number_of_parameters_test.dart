// ignore_for_file: prefer_match_file_name
// Check number of parameters fail
///
/// `number_of_parameters: max_parameters`
/// expect_lint: number_of_parameters
String numberOfParameters(String a, String b, String c) {
  return a + b + c;
}

//no lint
String avoidNumberOfParameters(String a, String b, String c) {
  return a + b + c;
}

class Exclude {
  //no lint
  String avoidNumberOfParameters(String a, String b, String c) {
    return a + b + c;
  }
}

class UserDto {
  final String email;
  final String firstName;
  final String id;
  final String imageUrl;
  final String lastName;

  final String phone;
  const UserDto({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.imageUrl,
    required this.email,
    required this.phone,
  });

  UserDto copyWith({
    String? email,
    String? firstName,
    String? id,
    String? imageUrl,
    String? lastName,
    String? phone,
  }) {
    return UserDto(
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
    );
  }
}
