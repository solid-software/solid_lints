A `late` keyword rule which forbids using it to avoid runtime exceptions.
### Parameters
#### **allow_initialized** (_bool_)  
  Allow immediately initialised late variables.

 ```dart
 late var ok = 0; // ok when allowInitialized == true
 late var notOk; // initialized elsewhere, not allowed
 ```
#### **ignored_types** (_Iterable&lt;String&gt;_)  
  Types that would be ignored by avoid-late rule
