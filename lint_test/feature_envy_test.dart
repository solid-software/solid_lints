// ignore_for_file: prefer_match_file_name

class Rectangle {
  final int height;
  final int width;
  const Rectangle(this.height, this.width);

  int get area => width * height;

  int getArea() => width * height;
}

class MathHelper {
  int sumOfAreas(Rectangle r1, Rectangle r2) =>
      //expect_lint: feature_envy
      (r1.width * r1.height) + (r2.width * r2.height);

  //no lint
  int sumOfAreasButGood(Rectangle r1, Rectangle r2) => r1.area + r2.area;

  int sumOfAreasButGood2(Rectangle r1, Rectangle r2) =>
      //no lint
      r1.getArea() + r2.getArea();
}
