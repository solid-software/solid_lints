/// Check the `use_descriptive_names_for_type_parameters` rule

// ignore_for_file: unused_element

// expect_lint: use_descriptive_names_for_type_parameters
class SomeClass<T, U, K> {}

class ValidClass<Type, Data, Context> {}

class TwoParams<T, U> {}

// expect_lint: use_descriptive_names_for_type_parameters
class AnotherClass<A, B, C, D> {}

// expect_lint: use_descriptive_names_for_type_parameters
void functionWithTypes<T, U, K>(T t, U u, K k) {}

void validFunction<Type, Data, Context>(Type t, Data d, Context c) {}

void functionWithGenericFunctionDeclarations() {
  // expect_lint: use_descriptive_names_for_type_parameters
  void _fail3<A, B, C>() {}

  void _pass2<D, E>() {}

  void _pass1<F>() {}

  void _pass0() {}
}

void twoTypeParams<T, U>(T t, U u) {}

// expect_lint: use_descriptive_names_for_type_parameters
class ComplexClass<X, Y, Z, W> {
  // expect_lint: use_descriptive_names_for_type_parameters
  void method<T, U, K>() {}
}

class ValidComplexClass<Type, Data, Context, State> {
  void validMethod<Key, Value, Result>() {}
}

// expect_lint: use_descriptive_names_for_type_parameters
typedef SomeAlias<T, U, K> = Map<T, Map<U, K>>;

typedef ValidAlias<Type, Data, Context> = Map<Type, Map<Data, Context>>;

typedef TwoParamAlias<T, U> = Map<T, U>;

// expect_lint: use_descriptive_names_for_type_parameters
extension Ext<T, U, K> on List<T> {}

extension ValidExt<Type, Data, Context> on List<Type> {}

// expect_lint: use_descriptive_names_for_type_parameters
mixin Mixin<T, U, K> {}

mixin ValidMixin<Type, Data, Context> {}
