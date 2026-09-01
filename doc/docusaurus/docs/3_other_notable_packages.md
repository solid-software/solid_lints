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

It uses a polynomial rolling hash engine with maximal bidirectional expansion to
detect token-level, structural, and parameterized code clones across packages.

- **Links**: [pub.dev](https://pub.dev/packages/dedupe) ·
  [GitHub](https://github.com/kevmoo/analytica.dart/tree/main/packages/dedupe)

### Comparison: `avoid_duplicate_code` vs `dedupe`

| Feature | `avoid_duplicate_code` | `dedupe` |
| :--- | :--- | :--- |
| **Tool type** | Dart Analyzer / Linter plugin rule | Standalone CLI tool & Dart library/API |
| **Primary workflow** | Real-time in-IDE feedback and `dart analyze` | Repository auditing, CI/CD checks, PR gating, batch analysis |
| **Core engine** | **AST Subtree Fingerprinting:** AST traversal and Jenkins One-at-a-time hashing | **Hybrid AST & Token Rolling Hash:** Rabin-Karp k-gram indexing and MinHash for gapped matches |
| **Code scope** | Syntactic blocks (functions, methods, closures, control-flow bodies) | Arbitrary token/line sequences (can detect clones across expression boundaries) |
| **Supported clone types** | • **Type 1** (exact copies)<br/>• **Type 2** (syntactic: renamed variables, differing literals) | • **Type 1** (exact copies)<br/>• **Type 2** (syntactic: renamed variables, differing literals)<br/>• **Type 3** (near-miss: copies with insertions, deletions, or statement changes) |
| **Differing literals diffing** | ✅ Detailed diff analysis reporting specific differing literal values | ❌ None (literals are normalized during extraction without per-value diffing) |
| **Git / PR delta integration** | ❌ None (analyzes the current state of workspace files) | ✅ Built-in for PR delta and modified lines scanning |
| **Report formats** | Dart Analysis Server diagnostics (IDE Problems, Related Locations) | Markdown, JSON, GitHub Actions step annotations, plain text |
| **Metrics & statistics** | Duplicate locations and differing literal values | Duplication percentages per file/package, cluster inventories, estimated lines saved |
| **Disk cache usage** | ✅ | ✅ |
