// ignore_for_file: avoid_returning_widgets, consider_making_a_member_private
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
    // expect_lint: no_magic_number
    decoration: MyWidgetDecoration(size: 12),
    // expect_lint: no_magic_number
    value: 23,
  );
}
