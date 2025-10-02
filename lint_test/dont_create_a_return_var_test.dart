// ignore_for_file: unused_local_variable, newline_before_return, no_empty_block

/// Test the dont_create_a_return_var.
/// Good code, trivial case.
int returnVarTestGoodTrivial() {
  return 1;
}

/// Test the dont_create_a_return_var.
/// Returning mutable variable should not trigger the lint.
int returnVarTestReturnMutable() {
  var a = 1;
  a++;

  return a;
}

int returnVarTestReturnParameter(int param) {
  return param;
}

/// Test the dont_create_a_return_var.
/// Caching mutable variable value.
/// Unpredictable: may be useful to cache value
/// before operation can change it.
int returnVarTestCachedMutable() {
  var a = 1;
  final result = a;
  _doNothing();

  return result;
}

/// Test the dont_create_a_return_var.
/// Caching mutable variable value, but return goes
/// right after declaration, which makes it bad.
int returnVarTestReturnFollowsDeclaration() {
  var a = 1;
  final result = a;

  //Some comment here

  //expect_lint: dont_create_a_return_var
  return result;
}

/// Test the dont_create_a_return_var.
/// Caching another method result.
/// Unpredictable: may be useful to cache value
/// before operation can change it.
int returnVarTestCachedAnotherMethodResult() {
  var a = 1;
  final result = _testValueEval();
  _doNothing();

  return result;
}

/// Test the dont_create_a_return_var.
/// Caching value of object's field.
/// Unpredictable: may be useful to cache value
/// before operation can change it.
int returnVarTestCachedObjectField() {
  final obj = _TestClass();
  final result = obj.varField;
  _doNothing();

  return result;
}

/// Test the dont_create_a_return_var.
/// Good: variable is created not only for return
/// but is used in following expressions as well.
int returnVarTestUsedVariable() {
  var a = 1;
  final result = 2;
  a += result;

  return result;
}

/// Test the dont_create_a_return_var.
/// Bad code, trivial example.
int returnVarTestBadTrivial() {
  final result = 1;

  //expect_lint: dont_create_a_return_var
  return result;
}

/// Test the dont_create_a_return_var.
/// Bad code: result expression is immutable,
/// so can be written in return statement directly.
int returnVarTestBadImmutableExpression() {
  const constLocal = 1;
  final finalLocal = 1;
  final testObj = _TestClass();
  final result = constLocal +
      finalLocal +
      1 + //const literal
      _TestClass.constValue +
      _TestClass.finalValue +
      testObj.finalField;
  _doNothing();

  //expect_lint: dont_create_a_return_var
  return result;
}

int _testValueEval() {
  return 1;
}

/// This method is a placeholder for unpredictable behaviour
/// which can potentially change any mutable variables
void _doNothing() {}

//ignore: prefer_match_file_name
class _TestClass {
  static const constValue = 1;
  static final finalValue = 1;
  //ignore: member_ordering
  final finalField = 1;
  var varField = 1;
}
