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

  //expect_lint: feature_envy
  int sumOfAreasButGood(Rectangle r1, Rectangle r2) => r1.area + r2.area;

  int sumOfAreasButGood2(Rectangle r1, Rectangle r2) =>
      //expect_lint: feature_envy
      r1.getArea() + r2.getArea();
}

class MathHelper2 {
  int field;
  MathHelper2(this.field);

  int fieldTriple() => field * field * field;

  //no lint
  int sumOfAreas(Rectangle r1, Rectangle r2) => r1.area + r2.area;
}

class MathHelper3 {
  int field;
  MathHelper3(this.field);

  int fieldDouble() => field * field;

  //no lint
  int sumOfAreas(Rectangle r1, Rectangle r2) => r1.area + r2.area;
}

class Cube {
  List<Rectangle> sides;
  Cube(this.sides);

  int get surfaceArea => sides.map((x) => x.area).reduce((a, b) => a + b);
}
