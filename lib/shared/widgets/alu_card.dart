import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';

/// Card with consistent padding and border radius. Responsive.
class AluCard extends StatelessWidget {
  const AluCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.borderRadius,
    this.borderSide,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final BorderSide? borderSide;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardTheme = theme.cardTheme;
    double effectiveRadius = borderRadius ?? AppConstants.cardBorderRadius;
    if (effectiveRadius == AppConstants.cardBorderRadius &&
        cardTheme.shape is RoundedRectangleBorder) {
      final shape = cardTheme.shape as RoundedRectangleBorder;
      final radius = shape.borderRadius;
      if (radius is BorderRadius) {
        effectiveRadius = radius.topLeft.x;
      }
    }
    final effectivePadding =
        padding ?? const EdgeInsets.all(AppConstants.screenPadding);

    Widget content = Padding(padding: effectivePadding, child: child);
    if (onTap != null) {
      content = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(effectiveRadius),
        child: content,
      );
    }

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(effectiveRadius),
        side: borderSide ??
            (cardTheme.shape is RoundedRectangleBorder
                ? (cardTheme.shape as RoundedRectangleBorder).side
                : BorderSide(
                    color: theme.dividerColor.withValues(alpha: 0.5),
                  )),
      ),
      color: cardTheme.color,
      child: content,
    );
  }
}
