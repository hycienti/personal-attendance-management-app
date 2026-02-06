import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';

/// Primary ALU-styled button. Responsive and accessible.
class AluButton extends StatelessWidget {
  const AluButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.loading = false,
    this.expand = true,
    this.style = AluButtonStyle.primary,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final bool expand;
  final AluButtonStyle style;

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = loading ? null : onPressed;
    final child = loading
        ? const SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.textOnPrimary,
            ),
          )
        : (icon != null
            ? Row(
                mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(label),
                  const SizedBox(width: 8),
                  Icon(icon, size: 20),
                ],
              )
            : Text(label));

    switch (style) {
      case AluButtonStyle.primary:
        return SizedBox(
          width: expand ? double.infinity : null,
          height: AppConstants.buttonHeight,
          child: FilledButton(
            onPressed: effectiveOnPressed,
            child: child,
          ),
        );
      case AluButtonStyle.secondary:
        return SizedBox(
          width: expand ? double.infinity : null,
          height: AppConstants.buttonHeight,
          child: OutlinedButton(
            onPressed: effectiveOnPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
            ),
            child: child,
          ),
        );
      case AluButtonStyle.text:
        return SizedBox(
          width: expand ? double.infinity : null,
          height: AppConstants.buttonHeight,
          child: TextButton(
            onPressed: effectiveOnPressed,
            child: child,
          ),
        );
    }
  }
}

enum AluButtonStyle { primary, secondary, text }
