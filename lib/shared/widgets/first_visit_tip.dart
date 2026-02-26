import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/services/tutorial_service.dart';

class FirstVisitTip extends ConsumerStatefulWidget {
  final String tipId;
  final String message;
  final IconData icon;

  const FirstVisitTip({
    super.key,
    required this.tipId,
    required this.message,
    this.icon = LucideIcons.lightbulb,
  });

  @override
  ConsumerState<FirstVisitTip> createState() => _FirstVisitTipState();
}

class _FirstVisitTipState extends ConsumerState<FirstVisitTip> {
  bool _visible = false;
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final service = ref.read(tutorialServiceProvider);
    final shouldShow = await service.shouldShowTip(widget.tipId);
    if (shouldShow && mounted) {
      setState(() => _visible = true);
    }
  }

  void _dismiss() {
    ref.read(tutorialServiceProvider).markTipSeen(widget.tipId);
    setState(() => _dismissed = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible || _dismissed) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  colorScheme.primary.withAlpha(22),
                  colorScheme.primary.withAlpha(10),
                ]
              : [
                  colorScheme.primary.withAlpha(16),
                  colorScheme.primaryContainer.withAlpha(40),
                ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.primary.withAlpha(isDark ? 30 : 25),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: colorScheme.primary.withAlpha(isDark ? 35 : 20),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              widget.icon,
              size: 15,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              widget.message,
              style: TextStyle(
                fontSize: 12.5,
                color: colorScheme.onSurface.withAlpha(200),
                height: 1.35,
              ),
            ),
          ),
          IconButton(
            onPressed: _dismiss,
            icon: Icon(
              LucideIcons.x,
              size: 14,
              color: colorScheme.onSurfaceVariant.withAlpha(120),
            ),
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 350.ms).slideY(begin: -0.15, end: 0);
  }
}
