---
title: Code Duplication
description: Detect duplicate code clones.
keywords:
  - code duplication
  - dedupe
  - avoid_duplicate_code
  - clone detection
  - dart duplicate code
sidebar_label: Code duplication
sidebar_position: 2
---

# Code Duplication

Tools and engines for detecting copy-pasted fragments and structural clones
across Dart and Flutter codebases.

## [dedupe](https://pub.dev/packages/dedupe)

[![pub package](https://img.shields.io/pub/v/dedupe.svg)](https://pub.dev/packages/dedupe)

High-performance code duplication and clone detection engine and CLI tool for
Dart and Flutter.

It scans codebases to detect token-level, structural, and near-miss code clones
across files and packages with fast incremental analysis.

- **Links**: [pub.dev](https://pub.dev/packages/dedupe) ·
  [GitHub](https://github.com/kevmoo/analytica.dart/tree/main/packages/dedupe)

## Comparison: [`avoid_duplicate_code`](../2_custom_lints/avoid_duplicate_code.md) vs `dedupe`

| | `avoid_duplicate_code` | `dedupe` |
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
