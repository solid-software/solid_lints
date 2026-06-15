// ignore_for_file: avoid_unused_parameters, unused_local_variable, function_lines_of_code, newline_before_return, member_ordering, avoid_non_null_assertion
import 'package:flutter/material.dart';

/// Check the `use_nearest_context` rule
void showDialog(BuildContext context) {
  final outerContext = context;

  showModalBottomSheet(
    context: context,
    builder: (BuildContext _) {
      /// expect_lint: use_nearest_context
      return SizedBox.fromSize(size: outerContext.size);
    },
  );

  showModalBottomSheet(
    context: context,
    builder: (BuildContext _) {
      /// expect_lint: use_nearest_context
      return SizedBox.fromSize(size: context.size);
    },
  );

  final fun = ({required BuildContext context}) {
    /// expect_lint: use_nearest_context
    outerContext.mounted;
  };

  showModalBottomSheet(
    context: context,
    builder: (_) {
      /// expect_lint: use_nearest_context
      return SizedBox.fromSize(size: context.size);
    },
  );

  showModalBottomSheet(
    context: context,
    builder: (BuildContext innerContext) {
      /// expect_lint: use_nearest_context
      return SizedBox.fromSize(size: context.size);
    },
  );

  showModalBottomSheet(
      context: context,
      builder: (BuildContext innerContext) {
        ///Allowed
        return SizedBox.fromSize(size: innerContext.size);
      });

  showModalBottomSheet(
    ///Allowed
    context: context,
    builder: (BuildContext context) {
      ///Allowed
      return SizedBox.fromSize(size: context.size);
    },
  );

  /// Nested builders: using outer builder's context instead of inner
  showModalBottomSheet(
    context: context,
    builder: (BuildContext outerBuilderCtx) {
      return Builder(
        builder: (BuildContext innerBuilderCtx) {
          /// expect_lint: use_nearest_context
          return SizedBox.fromSize(size: outerBuilderCtx.size);
        },
      );
    },
  );

  /// Callback without BuildContext inside builder:
  /// should lint when using outer context through a non-BuildContext callback
  showModalBottomSheet(
    context: context,
    builder: (BuildContext innerContext) {
      Future.microtask(() {
        /// expect_lint: use_nearest_context
        Navigator.of(context).pop();
      });

      return const SizedBox.shrink();
    },
  );

  /// Allowed: callback without BuildContext using nearest builder's context
  showModalBottomSheet(
    context: context,
    builder: (BuildContext innerContext) {
      Future.microtask(() {
        /// Allowed: innerContext is the nearest BuildContext
        Navigator.of(innerContext).pop();
      });

      return const SizedBox.shrink();
    },
  );
}

/// Check the `use_nearest_context` rule with class method context
class UseNearestContextTest extends StatefulWidget {
  @override
  State<UseNearestContextTest> createState() => _UseNearestContextTestState();

  const UseNearestContextTest({super.key});
}

class _UseNearestContextTestState extends State<UseNearestContextTest> {
  @override
  Widget build(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext _) {
        /// expect_lint: use_nearest_context
        return SizedBox.fromSize(size: context.size);
      },
    );

    /// Allowed: using method's own BuildContext directly
    return SizedBox.fromSize(size: context.size);
  }
}

/// Check the `use_nearest_context` rule within a constructor body.
class QuickFixBrokenTest {
  QuickFixBrokenTest(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext _) {
        /// expect_lint: use_nearest_context
        return SizedBox.fromSize(size: context.size);
      },
    );
  }
}

/// False positive checks: none of these should trigger the lint.
class FalsePositiveTest extends StatefulWidget {
  const FalsePositiveTest({super.key});

  @override
  State<FalsePositiveTest> createState() => _FalsePositiveTestState();
}

class _FalsePositiveTestState extends State<FalsePositiveTest> {
  @override
  Widget build(BuildContext context) {
    /// Case 1: Local variable assigned from nearest context —
    /// should NOT trigger, but currently does (false positive).
    showModalBottomSheet(
      context: context,
      builder: (BuildContext innerContext) {
        final BuildContext localContext = innerContext;

        /// Allowed: localContext is assigned from innerContext
        return SizedBox.fromSize(size: localContext.size);
      },
    );

    /// Case 2: Property of another object — state.context
    /// should NOT trigger, but currently does (false positive).
    showModalBottomSheet(
      context: context,
      builder: (BuildContext innerContext) {
        final state =
            (innerContext as Element).findAncestorStateOfType<State>()!;

        /// Allowed: state.context is a property access, not a direct use
        return SizedBox.fromSize(size: state.context.size);
      },
    );

    /// Case 3: this.context inside a builder — SHOULD trigger,
    /// because this.context is the outer scope's BuildContext.
    showModalBottomSheet(
      context: context,
      builder: (BuildContext innerContext) {
        /// expect_lint: use_nearest_context
        return SizedBox.fromSize(size: this.context.size);
      },
    );

    return const SizedBox.shrink();
  }
}
