import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

enum SnackBarType { success, error, info }

void showAppSnackBar(
  BuildContext context, {
  required String message,
  SnackBarType type = SnackBarType.info,
  Duration duration = const Duration(seconds: 3),
}) {
  final colorScheme = Theme.of(context).colorScheme;

  final (icon, bgColor, fgColor) = switch (type) {
    SnackBarType.success => (
        LucideIcons.checkCircle2,
        const Color(0xFF16A34A),
        Colors.white,
      ),
    SnackBarType.error => (
        LucideIcons.alertCircle,
        colorScheme.error,
        colorScheme.onError,
      ),
    SnackBarType.info => (
        LucideIcons.info,
        colorScheme.inverseSurface,
        colorScheme.onInverseSurface,
      ),
  };

  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, size: 18, color: fgColor),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: fgColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: bgColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        duration: duration,
      ),
    );
}
