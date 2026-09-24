---
title: Dead Code
description: Find and remove unused code.
keywords:
  - dead code
  - ciach
  - undead
  - unused code
  - dart dead code
sidebar_label: Dead code
sidebar_position: 1
---

# Dead Code

Tools for identifying, analyzing, and removing unreachable declarations,
forgotten APIs, and dead code across Dart and Flutter codebases.

## [ciach](https://pub.dev/packages/ciach)

[![pub package](https://img.shields.io/pub/v/ciach.svg)](https://pub.dev/packages/ciach)

A command-line tool acting as a wrapper around the **Dart Analysis Server**.
It queries the analysis server for explicit references to declarations in
the project.

`ciach` excels at deep codebase cleanup, inspecting internal class members,
methods, constructors, extensions, and fields.

- **Links**: [pub.dev](https://pub.dev/packages/ciach) ·
  [GitHub](https://github.com/leancodepl/ciach)

---

## [undead](https://pub.dev/packages/undead)

[![pub package](https://img.shields.io/pub/v/undead.svg)](https://pub.dev/packages/undead)

Deterministic reachability and dead/unused declaration analysis library and
CLI for Dart and Flutter packages.

It performs whole-package AST analysis using `package:analyzer` to build a
reachability graph from known entrypoints to all internal declarations,
identifying unused top-level declarations, classes, functions, and variables.

- **Links**: [pub.dev](https://pub.dev/packages/undead) ·
  [GitHub](https://github.com/kevmoo/analytica.dart/tree/main/packages/undead)

---

## Comparison: `ciach` vs `undead`

| | `ciach` | `undead` |
| :--- | :--- | :--- |
| **Detection Engine** | Queries the **Dart Analysis Server** for explicit references to declarations. | Parses AST and builds a **reachability graph** from known entrypoints. |
| **Analysis Depth** | **Deep:** Scans inside classes, including methods, constructors, extensions, and fields. | **Top-level:** Only identifies unused top-level declarations, classes, functions, and global variables. |
| **Test Handling** | Scans the included workspace files, including `test/` unless excluded. May flag reflection-invoked tests as dead code. | Recognizes package test suites and test-runner entrypoints; library mode uses public `lib/**` exports as reachability roots. |
| **Suppressions / Ignores** | ❌ **No inline comments.** (Requires CLI exclusions like `-e 'file'` or `@pragma`) | ✅ **Granular inline comments.** (Via `// undead:ignore` & `_for_file`) |
| **Auto-Removal** | ✅ **Supported** (via `--remove` flag) | ❌ **Analysis only** |

### Summary & Recommendations

- **Use `ciach`** when you want to aggressively find and clean up unused
  internal methods, fields, and members deep inside your application codebase,
  and you want an automated way to delete them.
- **Use `undead`** when you are building a reusable package or library and
  want to audit public API reachability, ensuring you don't expose forgotten
  top-level declarations.
