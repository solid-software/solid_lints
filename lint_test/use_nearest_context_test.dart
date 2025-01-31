// ignore_for_file: avoid_unused_parameters
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
}
