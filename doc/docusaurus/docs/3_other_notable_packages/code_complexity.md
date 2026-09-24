---
title: Code Complexity
description: Measure and manage code complexity.
keywords:
  - code complexity
  - cognitive_complexity
  - cyclomatic_complexity
  - code metrics
  - dart complexity
sidebar_label: Code complexity
sidebar_position: 3
---

# Code Complexity

Tools and metrics for analyzing algorithmic complexity and cognitive burden
in Dart and Flutter codebases.

## [cognitive_complexity](https://pub.dev/packages/cognitive_complexity)

[![pub package](https://img.shields.io/pub/v/cognitive_complexity.svg)](https://pub.dev/packages/cognitive_complexity)

Algorithmic Cognitive Complexity calculation and Data-Flow analysis library and
CLI tools for Dart and Flutter.

It implements the Cognitive Complexity principles articulated by SonarSource,
providing an objective way to find and fix overly complex logic and routines.

- **Links**: [pub.dev](https://pub.dev/packages/cognitive_complexity) ·
  [GitHub](https://github.com/kevmoo/analytica.dart/tree/main/packages/cognitive_complexity)

---

## Comparison: [`cyclomatic_complexity`](../2_custom_lints/cyclomatic_complexity.md) vs `cognitive_complexity`

Both tools aim to alert you when code becomes too complex to maintain, but they
evaluate complexity from different angles:

| | `cyclomatic_complexity` | `cognitive_complexity` |
| :--- | :--- | :--- |
| **Complexity angle** | **Structural:** Counts branches and execution paths | **Perceptual:** Evaluates mental effort and readability |
| **Nesting impact** | Treats all branches equally (+1 per branch) | Penalizes deeper nesting progressively |
| **When it flags** | Functions with too many execution paths | Functions that are hard for humans to follow |
| **Tool type** | Real-time IDE lint rule (`solid_lints`) | Standalone CLI tool & analysis library |

> **💡 Best Together:** Use `cyclomatic_complexity` in `solid_lints` to
> prevent sprawling branch counts, and `cognitive_complexity` to audit deeply
> nested routines that are hard to comprehend and maintain.
