// MIT License
//
// Copyright (c) 2020-2021 Dart Code Checker team
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

/// A data model enum represents annotation
enum Annotation {
  /// override annotation
  override('override', 'overridden'),

  /// protected annotation
  protected('protected'),

  /// Indicates missing annotation
  /// used to handle cases of unsupported annotations
  unset('unset');

  /// String representation of name of an annotation
  final String name;

  /// String representation of public name of an annotation
  final String? publicName;

  const Annotation(this.name, [this.publicName]);

  /// Parses a String name and returns instance of [Annotation]
  static Annotation parse(String? name) => values.firstWhere(
    (annotation) =>
        annotation.name == name ||
        (annotation.publicName != null && annotation.publicName == name),
    orElse: () => Annotation.unset,
  );
}
