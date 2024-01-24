# source-lines-of-code

We use the recommended value of **200** SLoC.

Reference:
McConnell, S. (2004), Chapter 7.4: High-Quality Routines: How Long Can a Routine Be?. Code Complete, Second Edition, Redmond, WA, USA: Microsoft Press. 173-174

## Tests

State: **Disabled**

Tests usually organized in one large `main()` function making this rule not applicable.

Given the quite large threshold configured for this metric we considered extracting test body into separate function, but that means that we'll have to do one of the following:

- Pass Test Context that contains all defined variables from `main` to every function call.
- Moving the variables to the Global State.

Both options didn't look right, so we decided that tests are ok to be long.
