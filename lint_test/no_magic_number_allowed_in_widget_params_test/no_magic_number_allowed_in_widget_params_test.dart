// ignore_for_file: avoid_returning_widgets
// ignore_for_file: prefer_match_file_name

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
    /// allowed_in_widget_params: true
    decoration: MyWidgetDecoration(size: 12),

    /// allowed_in_widget_params: true
    value: 23,
  );
}
