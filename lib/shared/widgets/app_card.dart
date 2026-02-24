import 'package:flutter/material.dart';

import '../../core/constants/app_spacing.dart';

/// Reusable card widget with consistent styling across the app.
/// Uses surfaceContainerHighest in dark mode and surface + border in light mode.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color? color;
  final Border? border;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = AppRadius.lg,
    this.onTap,
    this.onLongPress,
    this.color,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardColor = color ??
        (isDark
            ? colorScheme.surfaceContainerHighest
            : colorScheme.surface);

    final cardBorder = border ??
        Border.all(
          color: isDark
              ? colorScheme.outlineVariant.withAlpha(51)
              : colorScheme.outlineVariant,
        );

    Widget content = Container(
      padding: padding ?? const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: cardBorder,
      ),
      child: child,
    );

    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(borderRadius),
      child: onTap != null || onLongPress != null
          ? InkWell(
              onTap: onTap,
              onLongPress: onLongPress,
              borderRadius: BorderRadius.circular(borderRadius),
              child: content,
            )
          : content,
    );
  }
}
