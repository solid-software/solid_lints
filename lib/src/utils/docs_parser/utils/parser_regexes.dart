/// Regular expressions used by documentation parsers.
class ParserRegexes {
  ParserRegexes._();

  /// Pattern matching valid template/macro names.
  static const namePattern = '[a-zA-Z0-9_.-]+';

  /// Regex to find @docType annotations in doc comments.
  ///
  /// ### Example match:
  /// `/// @docType rule` -> captures `rule`
  ///
  /// ```
  /// Regex Fragment    | Meaning
  /// ==============================================================
  /// @docType          | Match literal '@docType'
  ///         \s+       | Match one or more spaces
  ///            (  )   | Capture group 1: match...
  ///             .+    | ... one or more of any character
  ///                $  | Match the end of the line
  /// ```
  static final docTypeRegex = RegExp(r'@docType\s+(.+)$', multiLine: true);

  /// Regex to match words/tokens in types.
  ///
  /// ### Example match:
  /// `List<double>` -> matches `List` and `double`
  ///
  /// ```
  /// Regex Fragment    | Meaning
  /// ==============================================================
  /// \b                | Match word boundary
  ///   \w+             | Match one or more word characters
  ///      \b           | Match word boundary
  /// ```
  static final wordRegex = RegExp(r'\b\w+\b');

  /// Regex to find uppercase letters preceded by a lowercase letter
  /// (for camelCase).
  ///
  /// ### Example match:
  /// `camelCase` -> matches `C`
  ///
  /// ```
  /// Regex Fragment    | Meaning
  /// ==============================================================
  /// (?<=     )        | Assert preceding matches...
  ///     [a-z]         | ... a lowercase letter
  ///          [A-Z]    | Match an uppercase letter
  /// ```
  static final camelCaseRegex = RegExp('(?<=[a-z])[A-Z]');

  /// Regex to find `{@template}` blocks and capture the name
  /// and raw content.
  ///
  /// ### Example match:
  /// `/// {@template my_name}`
  /// `/// content`
  /// `/// {@endtemplate}`
  /// -> captures name `my_name` and body `/// content`
  ///
  /// ```
  /// Regex Fragment                          | Meaning
  /// ======================================================================
  /// {@template                              | Match literal '{@template'
  ///           \s+                           | Match one or more spaces
  ///              (             )            | Capture group 1: template name
  ///               namePattern               | ... valid name characters
  ///                             \}          | Match literal closing brace '}'
  ///                               (   )     | Capture group 2: body content
  ///                                [\s\S]*? | ... matches any chars lazily
  /// {@endtemplate\}                         | Match literal closing tag
  /// ```
  static final templateRegex = RegExp(
    '{@template\\s+($namePattern)\\}([\\s\\S]*?){@endtemplate\\}',
  );

  /// Regex to match `{@macro}` invocations and capture the template name.
  ///
  /// ### Example match:
  /// `{@macro my_name}` -> captures `my_name`
  ///
  /// ```
  /// Regex Fragment                  | Meaning
  /// ======================================================================
  /// {@macro                         | Match literal '{@macro'
  ///        \s+                      | Match one or more spaces
  ///           (            )        | Capture group 1: template name
  ///            namePattern          | ... valid name characters
  ///                        \}       | Match literal closing brace '}'
  /// ```
  static final macroRegex = RegExp('{@macro\\s+($namePattern)\\}');

  /// Regex to match either template start or template end tags
  /// to strip them.
  ///
  /// ### Example match:
  /// Matches `{@template my_name}` and `{@endtemplate}`
  ///
  /// ```
  /// Regex Fragment                      | Meaning
  /// ======================================================================
  /// {@template                          | Match literal '{@template'
  ///           \s+                       | Match one or more spaces
  ///              namePattern            | Match valid name characters
  ///                           \}        | Match literal closing brace '}'
  /// |                                   | OR
  ///  {@endtemplate\}                    | Match literal closing tag
  /// ```
  static final templateTagRegex = RegExp(
    '{@template\\s+$namePattern\\}|{@endtemplate\\}',
  );
}
