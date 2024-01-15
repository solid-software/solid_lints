1. [prefer_match_file_name](#prefer_match_file_name)
2. [prefer_conditional_expressions](#prefer_conditional_expressions)
3. [prefer_first](#prefer_first)
4. [no_empty_block](#no_empty_block)
5. [member_ordering](#member_ordering)
6. [avoid_unnecessary_type_assertions](#avoid_unnecessary_type_assertions)
7. [no_magic_number](#no_magic_number)
8. [avoid_unnecessary_type_casts](#avoid_unnecessary_type_casts)
9. [avoid_unused_parameters](#avoid_unused_parameters)
10. [newline_before_return](#newline_before_return)
11. [proper_super_calls](#proper_super_calls)
12. [avoid_unrelated_type_assertions](#avoid_unrelated_type_assertions)
13. [avoid_unnecessary_setstate](#avoid_unnecessary_setstate)
14. [avoid_late_keyword](#avoid_late_keyword)
15. [prefer_last](#prefer_last)
16. [no_equal_then_else](#no_equal_then_else)
17. [avoid_returning_widgets](#avoid_returning_widgets)
18. [avoid_global_state](#avoid_global_state)
19. [avoid_non_null_assertion](#avoid_non_null_assertion)
20. [double_literal_format](#double_literal_format)



## prefer_match_file_name
A `prefer_match_file_name` rule which warns about
 mismatch between file name and declared element inside


## prefer_conditional_expressions
A `prefer_conditional_expressions` rule which warns about
 simple if statements that can be replaced with conditional expressions
### Parameters:
- **ignore_nested** (_bool_)  
  Should rule ignore nested if statements


## prefer_first
A `prefer_first` rule which warns about
 usage of iterable[0] or iterable.elementAt(0)


## no_empty_block
A `no_empty_block` rule which forbids having empty blocks.
 Excluding catch blocks and to-do comments


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


## avoid_unnecessary_type_assertions
An `avoid_unnecessary_type_assertions` rule which
 warns about unnecessary usage of `is` and `whereType` operators


## no_magic_number
A `no_magic_number` rule which forbids having numbers without variable
### Parameters:
- **allowed_numbers** (_Iterable&lt;num&gt;_)  
  List of allowed numbers
- **allowed_in_widget_params** (_bool_)  
  The flag indicates whether magic numbers are allowed as a Widget instance
 parameter.


## avoid_unnecessary_type_casts
An `avoid_unnecessary_type_casts` rule which
 warns about unnecessary usage of `as` operator


## avoid_unused_parameters
A `avoid_unused_parameters` rule which
 warns about unused parameters


## newline_before_return
A `newline_before_return` rule which
 warns about missing newline before return


## proper_super_calls
Checks that `super` calls in the initState and
 dispose methods are called in the correct order.


## avoid_unrelated_type_assertions
A `avoid_unrelated_type_assertions` rule which
 warns about unnecessary usage of `as` operator


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


## prefer_last
A `prefer_last` rule which warns about
 usage of iterable[length-1] or iterable.elementAt(length-1)


## no_equal_then_else
A `no_equal_then_else` rule which warns about
 unnecessary if statements and conditional expressions


## avoid_returning_widgets
A rule which forbids returning widgets from functions and methods.


## avoid_global_state
A global state rule which forbids using variables
 that can be globally modified.


## avoid_non_null_assertion
Rule which forbids using bang operator ("!")
 as it may result in runtime exceptions.


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

