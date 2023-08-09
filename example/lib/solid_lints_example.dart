void main() {
  sum(1, 1);
}

/// Sum of two numbers. Standard dart overflow rules apply.
int sum(int p1, int p2) => p1 + p2;

/// Check complexity fail
int calculate() {
  if (true) {
    if (true) {
      if (true) {
        if (true) {}
      }
    }
  }

  return 6 * 7;
}
