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
10. [cyclomatic_complexity](#cyclomatic_complexity)
11. [double_literal_format](#double_literal_format)
12. [function_lines_of_code](#function_lines_of_code)
13. [member_ordering](#member_ordering)
14. [newline_before_return](#newline_before_return)
15. [no_empty_block](#no_empty_block)
16. [no_equal_then_else](#no_equal_then_else)
17. [no_magic_number](#no_magic_number)
18. [number_of_parameters](#number_of_parameters)
19. [prefer_conditional_expressions](#prefer_conditional_expressions)
20. [prefer_first](#prefer_first)
21. [prefer_last](#prefer_last)
22. [prefer_match_file_name](#prefer_match_file_name)
23. [proper_super_calls](#proper_super_calls)

---

## avoid_global_state
A global state rule which forbids using variables
that can be globally modified.


## avoid_late_keyword
A `late` keyword rule which forbids using it to avoid runtime exceptions.
### Parameters:
- **allow_initialized** (_bool_)  
  Allow immediately initialised late variables.

 ```dart
 late var ok = 0; // ok when allowInitialized == true
 late var notOk; // initialized elsewhere, not allowed
 ```
- **ignored_types** (_Iterable&lt;String&gt;_)  
  Types that would be ignored by avoid-late rule


## avoid_non_null_assertion
Rule which forbids using bang operator ("!")
as it may result in runtime exceptions.


## avoid_returning_widgets
A rule which forbids returning widgets from functions and methods.


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

Example:
 ```dart
 void initState() {
   setState(() => foo = 'bar');  // lint
   changeState();                // lint
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
An `avoid_unnecessary_type_assertions` rule which
warns about unnecessary usage of `is` and `whereType` operators


## avoid_unnecessary_type_casts
An `avoid_unnecessary_type_casts` rule which
warns about unnecessary usage of `as` operator


## avoid_unrelated_type_assertions
A `avoid_unrelated_type_assertions` rule which
warns about unnecessary usage of `as` operator


## avoid_unused_parameters
A `avoid_unused_parameters` rule which
warns about unused parameters


## cyclomatic_complexity
A Complexity metric checks content of block and detects more easier solution
### Parameters:
- **max_complexity** (_int_)  
  Min value of complexity level


## double_literal_format
A `double_literal_format` rule which
checks that double literals should begin with 0. instead of just .,
and should not end with a trailing 0.
 ```dart
 BAD:
 var a = 05.23, b = .16e+5, c = -0.250, d = -0.400e-5;
 GOOD:
 var a = 5.23, b = 0.16e+5, c = -0.25, d = -0.4e-5;
 ```


## function_lines_of_code
A number of lines metric which checks whether we didn't exceed
the maximum allowed number of lines for a function.
### Parameters:
- **max_lines** (_int_)  
  Maximum number of lines


## member_ordering
A `member_ordering` rule which
warns about class members being in wrong order
Custom order can be provided through config
### Parameters:
- **groups_order** (_List&lt;MemberGroup&gt;_)  
  Config used for members of regular class
- **widgets_groups_order** (_List&lt;MemberGroup&gt;_)  
  Config used for members of widget class
- **alphabetize** (_bool_)  
  Indicates if params should be in alphabetical order
- **alphabetize_by_type** (_bool_)  
  Indicates if params should be in alphabetical order of their type


## newline_before_return
A `newline_before_return` rule which
warns about missing newline before return


## no_empty_block
A `no_empty_block` rule which forbids having empty blocks.
Excluding catch blocks and to-do comments


## no_equal_then_else
A `no_equal_then_else` rule which warns about
unnecessary if statements and conditional expressions


## no_magic_number
A `no_magic_number` rule which forbids having numbers without variable
### Parameters:
- **allowed_numbers** (_Iterable&lt;num&gt;_)  
  List of allowed numbers
- **allowed_in_widget_params** (_bool_)  
  The flag indicates whether magic numbers are allowed as a Widget instance
  parameter.


## number_of_parameters
A number of parameters metric which checks whether we didn't exceed
the maximum allowed number of parameters for a function or a method
### Parameters:
- **max_parameters** (_int_)  
  Maximum number of parameters


## prefer_conditional_expressions
A `prefer_conditional_expressions` rule which warns about
simple if statements that can be replaced with conditional expressions
### Parameters:
- **ignore_nested** (_bool_)  
  Should rule ignore nested if statements


## prefer_first
A `prefer_first` rule which warns about
usage of iterable[0] or iterable.elementAt(0)


## prefer_last
A `prefer_last` rule which warns about
usage of iterable[length-1] or iterable.elementAt(length-1)


## prefer_match_file_name
A `prefer_match_file_name` rule which warns about
mismatch between file name and declared element inside


## proper_super_calls
Checks that `super` calls in the initState and
dispose methods are called in the correct order.
