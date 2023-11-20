// Allowed for numbers in a Widget subtype parameters.
abstract interface class Widget {}

class StatelessWidget implements Widget {}

class MyWidget extends StatelessWidget {
  final MyWidgetDecoration decoration;
  final int value;

  MyWidget({
    required this.decoration,
    required this.value,
  });
}

class MyWidgetDecoration {
  final int size;

  MyWidgetDecoration({required this.size});
}

Widget build() {
  return MyWidget(
    decoration: MyWidgetDecoration(size: 12),
    value: 23,
  );
}
