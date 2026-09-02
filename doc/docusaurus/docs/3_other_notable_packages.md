---
sidebar_label: Other notable packages
sidebar_position: 3
---

# Other Notable Packages

Notable third-party tools that complement `solid_lints` in keeping Dart and
Flutter codebases clean, robust, and maintainable.

## [undead](https://pub.dev/packages/undead)

[![pub package](https://img.shields.io/pub/v/undead.svg)](https://pub.dev/packages/undead)

Deterministic reachability and dead/unused declaration analysis for Dart and
Flutter packages.

It performs whole-package AST analysis using `package:analyzer` to build a
reachability graph from known entrypoints to all internal declarations,
identifying unused top-level declarations, classes, functions, and variables.

- **Links**: [pub.dev](https://pub.dev/packages/undead) ·
  [GitHub](https://github.com/kevmoo/analytica.dart/tree/main/packages/undead)

---

## [cognitive_complexity](https://pub.dev/packages/cognitive_complexity)

[![pub package](https://img.shields.io/pub/v/cognitive_complexity.svg)](https://pub.dev/packages/cognitive_complexity)

Algorithmic Cognitive Complexity calculation and Data-Flow analysis library and
CLI tools for Dart and Flutter.

It implements the Cognitive Complexity principles articulated by SonarSource,
providing an objective way to find and fix overly complex logic and routines.

- **Links**: [pub.dev](https://pub.dev/packages/cognitive_complexity) ·
  [GitHub](https://github.com/kevmoo/analytica.dart/tree/main/packages/cognitive_complexity)

---

## [dedupe](https://pub.dev/packages/dedupe)

[![pub package](https://img.shields.io/pub/v/dedupe.svg)](https://pub.dev/packages/dedupe)

High-performance code duplication and clone detection engine and CLI tool for
Dart and Flutter.

It scans codebases to detect token-level, structural, and near-miss code clones
across files and packages with fast incremental analysis.

- **Links**: [pub.dev](https://pub.dev/packages/dedupe) ·
  [GitHub](https://github.com/kevmoo/analytica.dart/tree/main/packages/dedupe)

### Comparison: [`avoid_duplicate_code`](2_custom_lints/avoid_duplicate_code.md) vs `dedupe`

| Feature / Scenario | `avoid_duplicate_code` | `dedupe` |
| :--- | :--- | :--- |
| **Tool type** | Dart Analyzer / Linter plugin rule | Standalone CLI tool & Dart library/API |
| **Primary workflow** | Real-time in-IDE feedback and `dart analyze` | Repository auditing, CI/CD checks, PR gating, batch analysis |
| **Detection approach** | **Block-level (AST):** Analyzes complete syntactic structures (functions, methods, closures, `if`/`for` bodies) | **Sequence-level (Tokens):** Analyzes continuous sequences of code anywhere across files |
| **Whole functions & blocks**<br/>*(e.g., duplicated methods with renamed variables)* | ✅ **Detected** | ✅ **Detected** |
| **Sub-method fragments**<br/>*(e.g., 5–10 copied lines inside a 50-line method)* | ❌ **Skipped** (only evaluates complete blocks/methods) | ✅ **Detected** (flags duplicate snippets regardless of block boundaries) |
| **Near-miss / modified clones**<br/>*(e.g., copy-paste with an extra line or minor edit)* | ❌ **Skipped** (requires matching syntactic block structure) | ✅ **Detected** (fuzzy matching detects clones with insertions/deletions) |
| **Differing literals diffing** | ✅ **Detailed in-IDE diff** (pinpoints exact differing values, e.g. `'email'` vs `'sms'`) | ❌ **No per-value diff** (flags clone locations without a detailed literal breakdown) |
| **Reporting & diagnostics** | IDE Problems & Related Locations | Markdown, JSON, GitHub Actions annotations, % duplication metrics |
| **Disk cache usage** | ✅ | ✅ |

> **💡 Best Together:** Use `avoid_duplicate_code` for instant IDE feedback,
> and `dedupe` for CI/CD quality gates and repository-wide code clone audits.



