// ignore_for_file: unused_field, prefer_match_file_name, proper_super_calls, number_of_parameters, avoid_unused_parameters, member_ordering
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
  final String? profileId;

  // no lint
  UserProfile.orderedConstructor(
    this.profileId, {
    required super.accountType,
    super.userId,
    required this.name,
    required this.email,
    this.age,
    this.country,
    this.isActive = true,
  });

  UserProfile.partiallyOrderedConstructor(
    this.profileId, {
    required super.accountType,
    required this.email,
    this.age,
    // expect_lint: named_parameters_ordering
    required this.name,
    this.country,
    // expect_lint: named_parameters_ordering
    super.userId,
    this.isActive = true,
  });

  UserProfile.unorderedConstructor(
    String profileId, {
    this.age,
    // expect_lint: named_parameters_ordering
    super.userId,
    // expect_lint: named_parameters_ordering
    required super.accountType,
    this.country,
    // expect_lint: named_parameters_ordering
    required this.name,
    this.isActive = true,
    // expect_lint: named_parameters_ordering
    required this.email,
  }) : profileId = profileId;

  // no lint
  void orderedMethod({
    required String name,
    required String email,
    int? age,
    bool isActive = true,
  }) {
    return;
  }

  void partiallyOrderedMethod({
    required String name,
    int? age,
    // expect_lint: named_parameters_ordering
    required String email,
    bool isActive = true,
  }) {
    return;
  }

  void unorderedMethod({
    int? age,
    // expect_lint: named_parameters_ordering
    required String email,
    bool isActive = true,
    // expect_lint: named_parameters_ordering
    required String name,
  }) {
    return;
  }

  void mixedParameters(
    String accountType,
    String? userId, {
    int? age,
    // expect_lint: named_parameters_ordering
    required String email,
    bool isActive = true,
    // expect_lint: named_parameters_ordering
    required String name,
  }) {
    return;
  }
}

void functionExample({
  required String name,
  bool isActive = true,
  // expect_lint: named_parameters_ordering
  int? age,
  // expect_lint: named_parameters_ordering
  required String email,
}) {
  return;
}

void mixedParameters(
  String accountType,
  String? userId, {
  int? age,
  // expect_lint: named_parameters_ordering
  required String email,
  bool isActive = true,
  // expect_lint: named_parameters_ordering
  required String name,
}) {
  return;
}
