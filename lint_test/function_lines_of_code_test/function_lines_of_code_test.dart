class ClassWithLongMethods {
  int notLongMethod() {
    var i = 0;
    i++;
    i++;
    i++;
    return i;
  }

  // expect_lint: function_lines_of_code
  int longMethod() {
    var i = 0;
    i++;
    i++;
    i++;
    i++;
    return i;
  }

  // Excluded by excludeNames
  int longMethodExcluded() {
    var i = 0;
    i++;
    i++;
    i++;
    i++;
    return i;
  }
}

int notLongFunction() {
  var i = 0;
  i++;
  i++;
  i++;
  return i;
}

// expect_lint: function_lines_of_code
int longFunction() {
  var i = 0;
  i++;
  i++;
  i++;
  i++;
  return i;
}

// Excluded by excludeNames
int longFunctionExcluded() {
  var i = 0;
  i++;
  i++;
  i++;
  i++;
  return i;
}
