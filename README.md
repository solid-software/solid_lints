# Solid Lints
[![style: solid](https://img.shields.io/badge/style-solid-orange)](https://pub.dev/packages/solid_lints)
[![$solid_lints](https://nokycucwgzweensacwfy.supabase.co/functions/v1/get_project_badge?projectId=211)](https://nokycucwgzweensacwfy.supabase.co/functions/v1/get_project_url?projectId=211)


Flutter/Dart lints configuration based on software engineering industry standards (ISO/IEC, NIST) and best practices.

# Usage

Add dependency in your pubspec.yaml:

```yaml
dev_dependencies:
  solid_lints: <INSERT LATEST VERSION>
```

And then include `solid_lints` into your project top-level `analysis_options.yaml`:

```yaml
include: package:solid_lints/analysis_options.yaml
```

Also you can use a specialized rule set designed for Dart tests.
Add an `analysis_options.yaml` file under the `test/` directory, and include the ruleset:

```yaml
include: package:solid_lints/analysis_options_test.yaml
```

Then you can see suggestions in your IDE or you can run checks manually:

```bash
dart analyze;
```

# Badge

To indicate that your project is using Solid Lints, you can use the following badge:

```markdown
[![style: solid](https://img.shields.io/badge/style-solid-orange)](https://pub.dev/packages/solid_lints)
```

# Solid Lints Documentation

## Table of contents:

1. [avoid_global_state](#avoid_global_state)
2. [avoid_late_keyword](#avoid_late_keyword)
3. [avoid_non_null_assertion](#avoid_non_null_assertion)
4. [avoid_returning_widgets](#avoid_returning_widgets)
5. [avoid_unnecessary_setstate](#avoid_unnecessary_setstate)
6. [avoid_unnecessary_type_assertions](#avoid_unnecessary_type_assertions)
7. [avoid_unnecessary_type_casts](#avoid_unnecessary_type_casts)
8. [avoid_unrelated_type_assertions](#avoid_unrelated_type_assertions)
9. [avoid_unused_parameters](#avoid_unused_parameters)
10. [avoid_using_api](#avoid_using_api)
11. [cyclomatic_complexity](#cyclomatic_complexity)
12. [double_literal_format](#double_literal_format)
13. [function_lines_of_code](#function_lines_of_code)
14. [member_ordering](#member_ordering)
15. [newline_before_return](#newline_before_return)
16. [no_empty_block](#no_empty_block)
17. [no_equal_then_else](#no_equal_then_else)
18. [no_magic_number](#no_magic_number)
19. [number_of_parameters](#number_of_parameters)
20. [prefer_conditional_expressions](#prefer_conditional_expressions)
21. [prefer_first](#prefer_first)
22. [prefer_last](#prefer_last)
23. [prefer_match_file_name](#prefer_match_file_name)
24. [proper_super_calls](#proper_super_calls)

---

## avoid_global_state
Avoid top-level and static mutable variables.

Top-level variables can be modified from anywhere,
which leads to hard to debug applications.

Prefer using a state management solution.

### Example

#### BAD:

 ```dart
 var globalMutable = 0; // LINT

 class Test {
   static int globalMutable = 0; // LINT
 }
 ```


#### GOOD:

 ```dart
 final globalFinal = 1;
 const globalConst = 1;

 class Test {
   static const int globalConst = 1;
   static final int globalFinal = 1;
 }
 ```


## avoid_late_keyword
Avoid `late` keyword

Using `late` disables compile time safety for what would else be a nullable
variable. Instead, a runtime check is made, which may throw an unexpected
exception for an uninitialized variable.

### Example config:

 ```yaml
 custom_lint:
    rules:
      - avoid_late_keyword:
        allow_initialized: false
        ignored_types:
         - AnimationController
         - ColorTween
 ```

### Example

#### BAD:
 ```dart
 class AvoidLateKeyword {
   late final int field; // LINT

   void test() {
     late final local = ''; // LINT
   }
 }
 ```

#### GOOD:
 ```dart
 class AvoidLateKeyword {
   final int? field; // LINT

   void test() {
     final local = ''; // LINT
   }
 }
 ```
### Parameters:
- **allow_initialized** (_bool_)  
  Allow immediately initialized late variables.

 ```dart
 late var ok = 0; // ok when allowInitialized == true
 late var notOk; // initialized elsewhere, not allowed
 ```
- **ignored_types** (_Iterable&lt;String&gt;_)  
  Types that would be ignored by avoid-late rule

Example:

 ```yaml
 custom_lint:
   rules:
     - avoid_late_keyword:
       ignored_types:
         - ColorTween
 ```

 ```dart
 late ColorTween tween; // OK
 late int colorValue; // LINT
 ```


## avoid_non_null_assertion
Rule which warns about usages of bang operator ("!")
as it may result in unexpected runtime exceptions.

"Bang" operator with Maps is allowed, as [Dart docs](https://dart.dev/null-safety/understanding-null-safety#the-map-index-operator-is-nullable)
recommend using it for accessing Map values that are known to be present.

### Example
#### BAD:

 ```dart
 Object? object;
 int? number;

 final int computed = 1 + number!; // LINT
 object!.method(); // LINT
 ```

#### GOOD:
 ```dart
 Object? object;
 int? number;

 if (number != null) {
   final int computed = 1 + number;
 }
 object?.method();

 // No lint on maps
 final map = {'key': 'value'};
 map['key']!;
 ```


## avoid_returning_widgets
A rule which warns about returning widgets from functions and methods.

Using functions instead of Widget subclasses for decomposing Widget trees
may cause unexpected behavior and performance issues.

More details: https://github.com/flutter/flutter/issues/19269

### Example

#### BAD:

 ```dart
 Widget avoidReturningWidgets() => const SizedBox(); // LINT

 class MyWidget extends StatelessWidget {
   Widget _test1() => const SizedBox(); // LINT
   Widget get _test3 => const SizedBox(); // LINT
 }
 ```


#### GOOD:

 ```dart
 class MyWidget extends StatelessWidget {
   @override
   Widget build(BuildContext context) {
     return const SizedBox();
   }
 }
 ```


## avoid_unnecessary_setstate
A rule which warns when setState is called inside initState, didUpdateWidget
or build methods and when it's called from a sync method that is called
inside those methods.

Cases where setState is unnecessary:
- synchronous calls inside State lifecycle methods:
  - initState
  - didUpdateWidget
  - didChangeDependencies
- synchronous calls inside `build` method

Nested synchronous setState invocations are also disallowed.

Calling setState in the aforementioned methods is allowed for:
- async methods
- callbacks

### Example:
#### BAD:
 ```dart
 void initState() {
   setState(() => foo = 'bar');  // lint
   changeState();                // lint
 }

 void changeState() {
   setState(() => foo = 'bar');
 }

 void triggerFetch() async {
   await fetch();
   if (mounted) setState(() => foo = 'bar');
 }
 ```

#### GOOD:
 ```dart
 void initState() {
   triggerFetch();               // OK
   stream.listen((event) => setState(() => foo = event)); // OK
 }

 void changeState() {
   setState(() => foo = 'bar');
 }

 void triggerFetch() async {
   await fetch();
   if (mounted) setState(() => foo = 'bar');
 }
 ```


## avoid_unnecessary_type_assertions
Warns about unnecessary usage of `is` and `whereType` operators.

### Example:
#### BAD:
 ```dart
 final testList = [1.0, 2.0, 3.0];
 final result = testList is List<double>; // LINT
 final negativeResult = testList is! List<double>; // LINT
 testList.whereType<double>(); // LINT

 final double d = 2.0;
 final casted = d is double; // LINT
 ```

### OK:
 ```dart
 final dynamicList = <dynamic>[1.0, 2.0];
 dynamicList.whereType<double>();

 final double? nullableD = 2.0;
 // casting `Type? is Type` is allowed
 final castedD = nullableD is double;
 ```


## avoid_unnecessary_type_casts
An `avoid_unnecessary_type_casts` rule which
warns about unnecessary usage of `as` operator


## avoid_unrelated_type_assertions
A `avoid_unrelated_type_assertions` rule which
warns about unnecessary usage of `as` operator


## avoid_unused_parameters
Warns about unused function, method, constructor or factory parameters.

### Example:
#### BAD:
 ```dart
 void fun(String x) {} // LINT
 void fun2(String x, String y) { // LINT
   print(y);
 }

 class TestClass {
   static void staticMethod(int a) {} // LINT
   void method(String s) {} // LINT

   TestClass([int a]); // LINT
   factory TestClass.named(int a) { // LINT
     return TestClass();
   }
 }
 ```

### OK:
 ```dart
 void fun(String _) {} // Replacing with underscores silences the warning
 void fun2(String _, String y) {
   print(y);
 }

 class TestClass {
   static void staticMethod(int _) {} // OK
   void method(String _) {} // OK

   TestClass([int _]); // OK
   factory TestClass.named(int _) { // OK
     return TestClass();
   }
 }
 ```


## avoid_using_api
A `avoid_using_api` rule which
warns about usage of avoided APIs


### Usage

External code can be "deprecated" when there is a better option available:

 ```yaml
 custom_lint:
   rules:
     - avoid_using_api:
       severity: info
       entries:
         - class_name: Future
           identifier: wait
           source: dart:async
           reason: "Future.wait should be avoided because it loses type
                    safety for the results. Use a Record's `wait` method
                    instead."
           severity: warning
 ```

Result:

 ```dart
 void main() async {
   await Future.wait([...]); // LINT
   await (...).wait; // OK
 }
 ```

### Advanced Usage

Each entry also has `includes` and `excludes` parameters.
These paths utilize [Glob](https://pub.dev/packages/glob)
patterns to determine if a lint entry should be applied to a file.

For example, a lint to prevent usage of a domain-only package outside of the
domain folder:

 ```yaml
 custom_lint:
   rules:
     - avoid_using_api:
       severity: info
       entries:
         - source: package:domain_models
           excludes:
             - "**/domain/**.dart"
           reason: "domain_models is only intended to be used in the domain
                    layer."
 ```
### Parameters:
- **entries** (_List&lt;AvoidUsingApiEntryParameters&gt;_)  
  A list of BannedCodeOption parameters.
- **severity** (_ErrorSeverity?_)  
  The default severity of the lint for each entry.


## cyclomatic_complexity
Limit for the number of linearly independent paths through a program's
source code.

Counts the number of code branches and loop statements within function and
method bodies.

### Example config:

This configuration will allow 10 code branchings per function body before
triggering a warning.

 ```yaml
 custom_lint:
   rules:
     - cyclomatic_complexity:
       max_complexity: 10
 ```
### Parameters:
- **max_complexity** (_int_)  
  Threshold cyclomatic complexity level, exceeding it triggers a warning.


## double_literal_format
A `double_literal_format` rule which
checks that double literals should begin with 0. instead of just .,
and should not end with a trailing 0.

### Example

#### BAD:

 ```dart
 var a = 05.23, b = .16e+5, c = -0.250, d = -0.400e-5;
 ```

#### GOOD:

 ```dart
 var a = 5.23, b = 0.16e+5, c = -0.25, d = -0.4e-5;
 ```


## function_lines_of_code
An approximate metric of meaningful lines of source code inside a function,
excluding blank lines and comments.

### Example config:

 ```yaml
 custom_lint:
   rules:
     - function_lines_of_code:
       max_lines: 100
 ```
### Parameters:
- **max_lines** (_int_)  
  Maximum allowed number of lines of code (LoC) per function,
  exceeding this limit triggers a warning.


## member_ordering
A lint which allows to enforce a particular class member ordering
conventions.

### Configuration format

The configuration uses a custom syntax for specifying members for ordering:
 ```
 annotation_modifiers_membertype
 ```
Valid annotations: `overridden`, `protected`

Valid modifiers, in order of how they may appear in the final expression:
- `private` / `public`
- `static`
- `late`
- `var` / `final` / `const`
- `nullable`
- `named`
- `factory`
- `fields` / `getters` / `getters_setters` / `setters` / `constructors` /
  `methods` / `method`.


Here are some examples of valid ordering group patterns:

- `public_static_const_fields`
- `private_late_fields`
- `private_nullable_fields`
- `public_methods`
- `overridden_methods`

It's also possible to specify ordering for custom-named class members:
- `my_custom_name_method`
- `dispose_method`

### Example:

Assuming config:

 ```yaml
 custom_lint:
   rules:
     - member_ordering:
       alphabetize: true
       order:
         - fields
         - getters_setters
         - methods
 ```

#### BAD:

 ```dart
 class Example {
   int get getA => a; // LINT, getters-setters should be after fields

   final b = 1;
   final a = 1; // LINT, non-alphabetic order
   final c = 1;

   void method() {}
 }
 ```

#### GOOD:

 ```dart
 class Example {
   final a = 1;
   final b = 1;
   final c = 1;

   int get getA => a;

   void method() {}
 }
 ```
### Parameters:
- **groups_order** (_List&lt;MemberGroup&gt;_)  
  Config used for members of regular class
- **widgets_groups_order** (_List&lt;MemberGroup&gt;_)  
  Config used for members of Widget subclasses
- **alphabetize** (_bool_)  
  Boolean flag; indicates whether params should be in alphabetical order
- **alphabetize_by_type** (_bool_)  
  Boolean flag; indicates whether params should be in alphabetical order by
  their static type


## newline_before_return
Warns about missing newline before return in a code block

### Example

#### BAD:
 ```dart
 int fn() {
   final a = 0;
   return 1; // LINT
 }

 void fn2() {
   if (true) {
     final a = 0;
     return; // LINT
   }
 }
 ```

#### GOOD:
 ```dart
 int fn0() {
   return 1; // OK for single-line code blocks
 }

 Function getCallback() {
   return () {
     return 1; // OK
   };
 }

 int fn() {
   final a = 0;

   return 1; // newline added -- OK
 }

 void fn2() {
   if (true) {
     return; // right under a conditional -- OK
   }
 }
 ```


## no_empty_block
A `no_empty_block` rule which forbids having empty code blocks,
including function/method bodies and conditionals,
excluding catch blocks and to-do comments.

An empty code block often indicates missing code.

### Example

#### BAD:
 ```dart
 int fn() {} // LINT

 Function getCallback() {
   return (){}; // LINT
 }

 void main() {
   if (true) {} // LINT
 }
 ```

#### GOOD:
 ```dart
 int fn() {
  // TODO: complete this
 }

 Function getCallback() {
   return () {
     // TODO: actually do something
   };
 }

 void main() {
   if (true) {
     print('');
   }

   try {
     fn();
   } catch (_) {} // ignored by this rule
 }
 ```


## no_equal_then_else
Warns when "if"-"else" statements or ternary conditionals have identical
if and else condition handlers.


### Example

#### BAD:

 ```dart
 final valueA = 'a';
 final valueB = 'b';

 if (condition) { // LINT
   selectedValue = valueA;
 } else {
   selectedValue = valueA;
 }

 selectedValue = condition ? valueA : valueA; // LINT
 ```

#### GOOD:

 ```dart
 final valueA = 'a';
 final valueB = 'b';

 if (condition) {
   selectedValue = valueA;
 } else {
   selectedValue = valueB;
 }

 selectedValue = condition ? valueA : valueB;
 ```


## no_magic_number
A `no_magic_number` rule which forbids having numbers without variable

There is a number of exceptions, where number literals are allowed:
- Collection literals;
- DateTime constructor usages;
- In constant constructors, including Enums;
- As a default value for parameters;
- In constructor initializer lists;

### Example config:

 ```yaml
 custom_lint:
   rules:
     - no_magic_number:
       allowed: [12, 42]
       allowed_in_widget_params: true
 ```

### Example

#### BAD:
 ```dart
 double circumference(double radius) => 2 * 3.14 * radius; // LINT

 bool canDrive(int age, {bool isUSA = false}) {
   return isUSA ? age >= 16 : age > 18; // LINT
 }
 ```

#### GOOD:
 ```dart
 const pi = 3.14;
 const radiusToDiameterCoefficient = 2;
 double circumference(double radius) =>
   radiusToDiameterCoefficient * pi * radius;

 const usaDrivingAge = 16;
 const worldWideDrivingAge = 18;

 bool canDrive(int age, {bool isUSA = false}) {
   return isUSA ? age >= usaDrivingAge : age > worldWideDrivingAge;
 }
 ```

### Allowed
 ```dart
 class ConstClass {
   final int a;
   const ConstClass(this.a);
   const ConstClass.init() : a = 10;
 }

 enum ConstEnum {
   // Allowed in enum arguments
   one(1),
   two(2);

   final int value;
   const ConstEnum(this.value);
 }

 // Allowed in const constructors
 const classInstance = ConstClass(1);

 // Allowed in list literals
 final list = [1, 2, 3];

 // Allowed in map literals
 final map = {1: 'One', 2: 'Two'};

 // Allowed in indexed expression
 final result = list[1];

 // Allowed in DateTime because it doesn't have const constructor
 final apocalypse = DateTime(2012, 12, 21);

 // Allowed for defaults in constructors and methods.
 class DefaultValues {
   final int value;
   DefaultValues.named({this.value = 2});
   DefaultValues.positional([this.value = 3]);

   void methodWithNamedParam({int value = 4}) {}
   void methodWithPositionalParam([int value = 5]) {}
 }
 ```
### Parameters:
- **allowed_numbers** (_Iterable&lt;num&gt;_)  
  List of numbers excluded from analysis

Defaults to numbers commonly used for increments and index access:
`[-1, 0, 1]`.
- **allowed_in_widget_params** (_bool_)  
  Boolean flag, toggles analysis for raw numbers within Widget constructor
  call parameters.

When flag is set to `false`, it warns about any non-const numbers in
your layout:

 ```dart
 Widget build() {
   return MyWidget(
     decoration: MyWidgetDecoration(size: 12), // LINT
     value: 23,                                // LINT
     child: const SizedBox(width: 20)          // allowed for const
   );
 }
 ```

When flag is set to `true`, it allows non-const layouts with raw numbers:

 ```dart
 Widget build() {
   return MyWidget(
     decoration: MyWidgetDecoration(size: 12), // OK
     value: 23, // OK
     child: const SizedBox(width: 20) // OK as it was
   );
 }
 ```


## number_of_parameters
A number of parameters metric which checks whether we didn't exceed
the maximum allowed number of parameters for a function, method or
constructor.

### Example:

Assuming config:

 ```yaml
 custom_lint:
   rules:
     - number_of_parameters:
       max_parameters: 2
 ```

#### BAD:
 ```dart
 void fn(a, b, c) {} // LINT
 class C {
   void method(a, b, c) {} // LINT
 }
 ```

#### GOOD:
 ```dart
 void fn(a, b) {} // OK
 class C {
   void method(a, b) {} // OK
 }
 ```
### Parameters:
- **max_parameters** (_int_)  
  Maximum number of parameters allowed before a warning is triggered.


## prefer_conditional_expressions
Highlights simple "if" statements that can be replaced with conditional
expressions

### Example config:

 ```yaml
 custom_lint:
   rules:
     - prefer_conditional_expressions:
       ignore_nested: true
 ```

### Example

#### BAD:

 ```dart
 // LINT
 if (x > 0) {
   x = 1;
 } else {
   x = 2;
 }

 // LINT
 if (x > 0) x = 1;
 else x = 2;

 int fn() {
   // LINT
   if (x > 0) {
     return 1;
   } else {
     return 2;
   }
 }
 ```

#### GOOD:

 ```dart
 x = x > 0 ? 1 : 2;

 int fn() {
   return x > 0 ? 1 : 2;
 }
 ```
### Parameters:
- **ignore_nested** (_bool_)  
  Determines whether to ignore nested if statements:

 ```dart
  // Allowed if ignore_nested flag is enabled
  if (1 > 0) {
    _result = 1 > 2 ? 2 : 1;
  } else {
    _result = 0;
  }
 ```


## prefer_first
Warns about usage of iterable[0] or iterable.elementAt(0) instead of
iterable.first.

### Example

#### BAD:

 ```dart
 final a = [1, 2, 3];

 a[0];           // LINT
 a.elementAt(0); // LINT
 ```

#### BAD:

 ```dart
 final a = [1, 2, 3];

 a.first; // OK
 ```


## prefer_last
Warns about usage of `iterable[length - 1]` or
`iterable.elementAt(length - 1)` instead of `iterable.last`.

### Example

#### BAD:

 ```dart
 final a = [1, 2, 3];

 a[a.length - 1];           // LINT
 a.elementAt(a.length - 1); // LINT
 ```

#### BAD:

 ```dart
 final a = [1, 2, 3];

 a.last; // OK
 ```


## prefer_match_file_name
Warns about a mismatch between file name and first declared element inside.


### Example

#### BAD:

File name: my_class.dart

 ```dart
 class NotMyClass {} // LINT
 ```

File name: other_class.dart

 ```dart
 class _OtherClass {}
 class SomethingPublic {}  // LINT
 ```

#### GOOD:

File name: my_class.dart

 ```dart
 class MyClass {} // OK
 ```

File name: something_public.dart

 ```dart
 class _OtherClass {}
 class SomethingPublic {}  // OK
 ```


## proper_super_calls
Ensures that `super` calls are made in the correct order for the following
StatefulWidget methods:

- `initState`
- `dispose`

### Example

#### BAD:

 ```dart
 @override
 void initState() {
   print('');
   super.initState(); // LINT, super.initState should be called first.
 }

 @override
 void dispose() {
   super.dispose(); // LINT, super.dispose should be called last.
   print('');
 }
 ```

#### GOOD:

 ```dart
 @override
void initState() {
  super.initState(); // OK
  print('');
}

@override
void dispose() {
  print('');
  super.dispose(); // OK
}
 ```
