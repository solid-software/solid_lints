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
