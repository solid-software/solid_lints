// ignore_for_file: consider_making_a_member_private
/// Check number of parameters fail
///
/// `number_of_parameters: max_parameters`
/// expect_lint: number_of_parameters
String numberOfParameters(String a, String b, String c) {
  return a + b + c;
}
