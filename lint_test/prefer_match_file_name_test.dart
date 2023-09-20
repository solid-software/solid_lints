// ignore_for_file: unused_element, unused_field

/// Check the `prefer-match-file-name` rule
class _AnotherPrivateClass {}

class PreferMatchFileNameTest {}

/// Only first public element declaration is checked
class WrongClass {}

class _PrivateClass {}

extension _PrivateExtension on PreferMatchFileNameTest {}

enum _PrivateEnum { a, b }

mixin _PrivateMixin {}
