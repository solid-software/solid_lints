# avoid_late_keyword

## Tests

State: **Disabled**.

Late keyword is allowed in tests in order to enable the use of custom mocks and
fakes.

It has several benefits over its alternatives (see below):

- Allows initialising the mocks inside the `setUp` method.
- Allows resetting mocks by re-initialising them inside `setUp`
- Allows passing the mock inside functions that require non-null params,
  without any extra force-unwraps or null checks.
- Uninitialized test mocks are clearly traceable.
- Produces minimal visual clutter.

Alternatives considered:

1. Making the mocks `final` and non-nullable, and adding a `reset()` method
   to them, which would return the mock/fake to its initial state.
   - Works well with generated code from testing libraries like `mockito`.
   - It's less practical with hand-written mocks, where it's possible to add a
     piece of state and forget to reset it, which might lead to hard-to-trace
     errors. Usually re-instantiating a test mock simplifies its code and
     prevents such errors altogether, but that requires making the field
     non-final, as well as delegating its initialisation to the `setUp` method.
2. Making the mocks nullable, and using `.?` access syntax.
   - In many cases will cause harder-to-trace testcase failures, if a mock was
     not initialised.
   - Does not allow passing the nullable mock into constructors/methods that
     require a non-nullable input.
3. Making the mocks nullable, and adding null-checks in test code.
   - Will lead to significant code bloat, without much benefit, as a null mock
     will still usually lead to a failed test.
4. Making the mocks nullable and using the "bang" operator (`!`):
   - In terms of behavior similar to `late`, but requires using the operator in
     many places inside the test code, adding uninformative visual noise.
   - The use of this operator is also discouraged by the main ruleset.
