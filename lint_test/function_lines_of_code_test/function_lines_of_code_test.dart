class ExcludeClass {
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
  int excludeMethod() {
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
int excludeFunction() {
  var i = 0;
  i++;
  i++;
  i++;
  i++;
  return i;
}

class ExcludeEntireClass {
  int longFunction() {
    var i = 0;
    i++;
    i++;
    i++;
    i++;
    return i;
  }
}
