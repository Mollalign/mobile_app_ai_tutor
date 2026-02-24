import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Consistent branded logo widget used across the app.
/// Gradient sparkles icon with optional glow effect.
class AppLogo extends StatelessWidget {
  final double size;
  final bool showGlow;

  const AppLogo({
    super.key,
    this.size = 48,
    this.showGlow = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary,
            colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: showGlow && isDark
            ? [
                BoxShadow(
                  color: colorScheme.primary.withAlpha(51),
                  blurRadius: size * 0.4,
                  offset: const Offset(0, 2),
                ),
              ]
            : showGlow
                ? [
                    BoxShadow(
                      color: colorScheme.primary.withAlpha(38),
                      blurRadius: size * 0.3,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
      ),
      child: Icon(
        LucideIcons.sparkles,
        size: size * 0.5,
        color: Colors.white,
      ),
    );
  }
}
