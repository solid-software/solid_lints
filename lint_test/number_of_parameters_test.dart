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
