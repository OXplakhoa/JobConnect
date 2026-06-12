import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_durations.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import 'animated_pressable.dart';

enum PremiumButtonVariant { primary, secondary, ai, ghost, destructive }

class PremiumButton extends StatelessWidget {
  const PremiumButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.variant = PremiumButtonVariant.primary,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final bool isLoading;
  final PremiumButtonVariant variant;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isEnabled = onPressed != null && !isLoading;
    final fg = _foregroundFor(brightness);
    final bg = _backgroundFor(brightness);

    final content = AnimatedOpacity(
      duration: AppDurations.state,
      opacity: isEnabled ? 1 : 0.48,
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: AppRadii.button,
        ),
        constraints:
            const BoxConstraints(minHeight: AppSpacing.buttonHeight),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space4,
          vertical: AppSpacing.space3,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
          children: [
            if (isLoading) ...[
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(fg),
                ),
              ),
              const SizedBox(width: AppSpacing.space3),
            ] else if (icon != null) ...[
              IconTheme(
                data: IconThemeData(color: fg, size: 18),
                child: icon!,
              ),
              const SizedBox(width: AppSpacing.space2),
            ],
            // When the button stretches (expand), its width is bounded by the
            // parent — let the label shrink/ellipsize instead of overflowing.
            // Content-sized buttons (expand: false) size to the full label.
            if (expand)
              Flexible(
                child: Text(
                  label,
                  style: AppTextStyles.label.copyWith(color: fg),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            else
              Text(label, style: AppTextStyles.label.copyWith(color: fg)),
          ],
        ),
      ),
    );

    return AnimatedPressable(
      onTap: isEnabled ? onPressed : null,
      borderRadius: AppRadii.button,
      enabled: isEnabled,
      child: content,
    );
  }

  Color _foregroundFor(Brightness brightness) {
    return switch (variant) {
      PremiumButtonVariant.primary || PremiumButtonVariant.ai =>
        AppColors.onAccent,
      PremiumButtonVariant.secondary => AppColors.inkFor(brightness),
      PremiumButtonVariant.ghost => AppColors.accent,
      PremiumButtonVariant.destructive => AppColors.errorFor(brightness),
    };
  }

  Color _backgroundFor(Brightness brightness) {
    return switch (variant) {
      PremiumButtonVariant.primary || PremiumButtonVariant.ai =>
        AppColors.accent,
      PremiumButtonVariant.secondary =>
        AppColors.surfaceVariantFor(brightness),
      PremiumButtonVariant.ghost || PremiumButtonVariant.destructive =>
        Colors.transparent,
    };
  }
}
