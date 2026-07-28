import 'package:solid_lints/src/common/parameters/excluded_identifiers_list_parameter.dart';

/// Configuration parameters for the avoid_duplicate_code rule.
class AvoidDuplicateCodeParameters {
  /// Minimum number of tokens in a function body or block required for it to
  /// be included in clone detection. Shorter bodies/blocks are ignored.
  ///
  /// :::note What is a Token?
  /// The smallest indivisible syntactic unit of code emitted by the compiler's
  /// lexer (keywords `final`, `if`, `switch`; identifiers; operators `=`, `=>`;
  /// punctuation `{`, `}`, `;` and literals).
  /// :::
  ///
  /// Considering the modern and concise syntax of Dart 3+ (switch expressions,
  /// pattern matching, record destructuring), the optimal default threshold
  /// was determined to be **30 tokens** (approximately 4-6 lines of meaningful
  /// code). This automatically filters out trivial single-line expressions and
  /// focuses exclusively on substantial logic blocks.
  ///
  /// ##### Example 1: Less than 30 tokens (Ignored): 26 tokens
  /// A concise switch expression in Dart 3 syntax contains **26 tokens** and
  /// is ignored:
  /// ```dart
  /// Color getShapeColor(Shape shape) => switch (shape) { // 6 tokens
  ///       Circle(:final color) => color,                 // 9 tokens
  ///       Square(:final color) => color,                 // 9 tokens
  ///     };                                               // 2 tokens
  /// ```
  ///
  /// ##### Example 2: 30+ tokens (Checked for duplicates): 34 tokens
  /// A function with record destructuring and pattern matching in Dart 3 syntax
  /// contains **34 tokens** and is checked for duplicates:
  /// ```dart
  /// String processUser(Object user) {                 // 1 token
  ///   if (user case User(:final name, :final age)     // 14 tokens
  ///       when age >= 18) {                           // 6 tokens
  ///     final status = 'Adult';                       // 5 tokens
  ///     return '$status: $name ($age)';               // 3 tokens
  ///   }                                               // 1 token
  ///   return 'Guest';                                 // 3 tokens
  /// }                                                 // 1 token
  /// ```
  final int minTokens;

  /// When `true`, literal values (strings, numbers, booleans) are excluded
  /// from the structural hash, ignoring literal differences during duplicate
  /// search.
  ///
  /// ##### Example:
  /// ```dart
  /// // Function A
  /// double calculateTax(double amount) {
  ///   final tax = amount * 0.20;
  ///   return amount + tax;
  /// }
  ///
  /// // Function B (differs only by literal 0.15 vs 0.20)
  /// double calculateDiscount(double amount) {
  ///   final tax = amount * 0.15;
  ///   return amount + tax;
  /// }
  /// ```
  /// * **When `ignore_literals: false` (default):** **NOT reported**
  ///   because numbers `0.20` and `0.15` differ.
  /// * **When `ignore_literals: true`:** **Reported as duplicate**
  ///   because literal values are ignored.
  final bool ignoreLiterals;

  /// When `true`, local variable and parameter names are excluded from the
  /// structural hash (using Sequential Variable Indexing). This enables
  /// detection of renamed variable clones (Type 2). Note that method, class,
  /// and field names are NOT ignored to prevent excessive false positives.
  ///
  /// ##### Example:
  /// ```dart
  /// // Function A
  /// double calcTotal(double price, int count) {
  ///   final subtotal = price * count;
  ///   return subtotal > 100 ? subtotal * 0.9 : subtotal;
  /// }
  ///
  /// // Function B (renamed: price->amount, count->qty, subtotal->total)
  /// double calcTotal(double amount, int qty) {
  ///   final total = amount * qty;
  ///   return total > 100 ? total * 0.9 : total;
  /// }
  /// ```
  /// * **When `ignore_identifiers: true` (default):** **Reported as**
  ///   **duplicate** (Type 2 Clone).
  /// * **When `ignore_identifiers: false`:** **NOT reported as duplicate**
  ///   because local names differ.
  final bool ignoreIdentifiers;

  /// When `true`, statement blocks (such as `if` blocks or loops) inside
  /// functions are also checked for duplication.
  ///
  /// ##### Example:
  /// ```dart
  /// // Function A
  /// void processUser(User user) {
  ///   print('Starting user process...');
  ///   if (user.isActive) {
  ///     logger.log('Processing user');
  ///     user.lastActive = DateTime.now();
  ///     user.status = UserStatus.active;
  ///     repository.save(user);
  ///     analytics.track('user_processed', user.id);
  ///   }
  /// }
  ///
  /// // Function B (different function, same inner if block)
  /// void processAdmin(User user) {
  ///   validateAdmin(user);
  ///   if (user.isActive) {
  ///     logger.log('Processing user');
  ///     user.lastActive = DateTime.now();
  ///     user.status = UserStatus.active;
  ///     repository.save(user);
  ///     analytics.track('user_processed', user.id);
  ///   }
  /// }
  /// ```
  /// * **When `check_blocks: true` (default):** **Reported as duplicate**
  ///   for the inner `if` block.
  /// * **When `check_blocks: false`:** **NOT reported as duplicate**
  ///   because nested `{ ... }` block nodes are skipped.
  final bool checkBlocks;

  /// A list of methods/functions that should be excluded from clone detection.
  final ExcludedIdentifiersListParameter exclude;

  static const _defaultMinTokens = 30;

  static final _defaultExclude = ExcludedIdentifiersListParameter(
    exclude: const [],
  );

  /// Constructor for [AvoidDuplicateCodeParameters] model.
  const AvoidDuplicateCodeParameters({
    required this.minTokens,
    required this.ignoreLiterals,
    required this.ignoreIdentifiers,
    required this.checkBlocks,
    required this.exclude,
  });

  /// Empty [AvoidDuplicateCodeParameters] model with default values.
  factory AvoidDuplicateCodeParameters.empty() => AvoidDuplicateCodeParameters(
    minTokens: _defaultMinTokens,
    ignoreLiterals: false,
    ignoreIdentifiers: true,
    checkBlocks: true,
    exclude: _defaultExclude,
  );

  /// Creates parameters from JSON configuration.
  factory AvoidDuplicateCodeParameters.fromJson(Map<String, Object?> json) =>
      AvoidDuplicateCodeParameters(
        minTokens: json['min_tokens'] as int? ?? _defaultMinTokens,
        ignoreLiterals: json['ignore_literals'] as bool? ?? false,
        ignoreIdentifiers: json['ignore_identifiers'] as bool? ?? true,
        checkBlocks: json['check_blocks'] as bool? ?? true,
        exclude: ExcludedIdentifiersListParameter.defaultFromJson(json),
      );

  /// Converts the parameters to a JSON-compatible Map.
  Map<String, Object?> toJson() => {
    'min_tokens': minTokens,
    'ignore_literals': ignoreLiterals,
    'ignore_identifiers': ignoreIdentifiers,
    'check_blocks': checkBlocks,
    'exclude': exclude.exclude.map((e) => e.toJson()).toList(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AvoidDuplicateCodeParameters &&
          other.minTokens == minTokens &&
          other.ignoreLiterals == ignoreLiterals &&
          other.ignoreIdentifiers == ignoreIdentifiers &&
          other.checkBlocks == checkBlocks &&
          other.exclude == exclude;

  @override
  int get hashCode => Object.hash(
    minTokens,
    ignoreLiterals,
    ignoreIdentifiers,
    checkBlocks,
    exclude,
  );
}
