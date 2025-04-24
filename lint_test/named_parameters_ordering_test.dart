// ignore_for_file: unused_field, prefer_match_file_name, proper_super_calls, number_of_parameters
// ignore_for_file: unused_element
// ignore_for_file: no_empty_block

/// Check the `named_parameters_ordering` rule

class User {
  final String accountType;
  final String? userId;

  User({
    this.userId,
    // expect_lint: named_parameters_ordering
    required this.accountType,
  });
}

class UserProfile extends User {
  final String? age;
  final String? country;
  final String email;
  final bool isActive;
  final String name;

  // no lint
  UserProfile.orderedConstructor({
    required this.name,
    required this.email,
    required super.accountType,
    this.isActive = true,
    this.age,
    this.country,
    super.userId,
  });

  UserProfile.partiallyOrderedConstructor({
    required super.accountType,
    // expect_lint: named_parameters_ordering
    required this.email,
    this.age,
    // expect_lint: named_parameters_ordering
    required this.name,
    this.country,
    // expect_lint: named_parameters_ordering
    this.isActive = true,
    super.userId,
  });

  UserProfile.unorderedConstructor({
    this.age,
    // expect_lint: named_parameters_ordering
    required super.accountType,
    // expect_lint: named_parameters_ordering
    required this.name,
    super.userId,
    // expect_lint: named_parameters_ordering
    this.country,
    // expect_lint: named_parameters_ordering
    this.isActive = true,
    // expect_lint: named_parameters_ordering
    required this.email,
  });

  void orderedMethod({
    required String name,
    required String email,
    bool isActive = true,
    int? age,
  }) {
    return;
  }

  void partiallyOrderedMethod({
    required String name,
    required String email,
    int? age,
    // expect_lint: named_parameters_ordering
    bool isActive = true,
  }) {
    return;
  }

  void unorderedMethod({
    required String name,
    int? age,
    // expect_lint: named_parameters_ordering
    bool isActive = true,
    // expect_lint: named_parameters_ordering
    required String email,
  }) {
    return;
  }
}

void functionExample({
  required String name,
  int? age,
  // expect_lint: named_parameters_ordering
  bool isActive = true,
  // expect_lint: named_parameters_ordering
  required String email,
}) {
  return;
}
