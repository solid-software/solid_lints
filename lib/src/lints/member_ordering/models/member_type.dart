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

import 'package:collection/collection.dart';

/// A data model enum represents class member type affiliation
enum MemberType {
  /// Indicates fields affiliation
  field('fields'),

  /// Indicates method affiliation
  method('methods', typeAlias: 'method'),

  /// Indicates constructor affiliation
  constructor('constructors'),

  /// Indicates getters affiliation
  getter('getters'),

  /// Indicates setters affiliation
  setter('setters'),

  /// Indicates affiliation with both getters and setters
  getterAndSetter('getters_setters');

  /// String representation of member group type
  final String type;

  /// Alternative string representation of member group type
  final String? typeAlias;

  const MemberType(this.type, {this.typeAlias});

  /// Parses a String member type and returns instance of [MemberType]
  static MemberType? parse(String? name) => values.firstWhereOrNull(
    (type) => name == type.type || name == type.typeAlias,
  );
}
