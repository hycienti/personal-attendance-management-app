import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';

/// Constrains content to max width and centers on large screens.
class ResponsiveContainer extends StatelessWidget {
  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
  });

  final Widget child;
  final double? maxWidth;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final effectiveMaxWidth = maxWidth ?? AppConstants.maxContentWidth;
    final effectivePadding = padding ??
        const EdgeInsets.symmetric(horizontal: AppConstants.screenPadding);

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: effectiveMaxWidth),
        child: Padding(
          padding: effectivePadding,
          child: child,
        ),
      ),
    );
  }
}
