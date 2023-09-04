// ignore_for_file: literal_only_boolean_expressions

/// Check complexity fail
///
/// `cyclomatic_complexity_metric: max_complexity`
/// expect_lint: cyclomatic_complexity
void cyclomaticComplexity() {
  if (true) {
    if (true) {
      if (true) {
        if (true) {}
      }
    }
  }
}
