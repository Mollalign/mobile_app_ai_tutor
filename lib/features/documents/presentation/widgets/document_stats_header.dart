import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../domain/entities/entities.dart';

/// Header showing document statistics.
class DocumentStatsHeader extends StatelessWidget {
  final DocumentStats stats;

  const DocumentStatsHeader({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primaryContainer,
            colorScheme.primaryContainer.withAlpha(200),
          ],
        ),
        borderRadius: AppRadius.borderRadiusMd,
      ),
      child: Row(
        children: [
          _StatItem(
            icon: LucideIcons.fileText,
            label: 'Total',
            value: stats.totalDocuments.toString(),
            color: colorScheme.primary,
          ),
          _buildDivider(context),
          _StatItem(
            icon: LucideIcons.checkCircle2,
            label: 'Ready',
            value: stats.readyDocuments.toString(),
            color: colorScheme.primary,
          ),
          if (stats.inProgressCount > 0) ...[
            _buildDivider(context),
            _StatItem(
              icon: LucideIcons.loader,
              label: 'Processing',
              value: stats.inProgressCount.toString(),
              color: colorScheme.tertiary,
            ),
          ],
          if (stats.failedDocuments > 0) ...[
            _buildDivider(context),
            _StatItem(
              icon: LucideIcons.alertCircle,
              label: 'Failed',
              value: stats.failedDocuments.toString(),
              color: colorScheme.error,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      color: Theme.of(context).colorScheme.outlineVariant,
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                value,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
