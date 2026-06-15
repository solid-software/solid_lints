// ignore_for_file: avoid_unused_parameters, unused_local_variable, function_lines_of_code, newline_before_return
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
