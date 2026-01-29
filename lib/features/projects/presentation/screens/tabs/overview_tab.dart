import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../../core/constants/app_spacing.dart';
import '../../../domain/entities/entities.dart';

/// Overview tab showing project information and stats.
class OverviewTab extends ConsumerWidget {
  final Project project;

  const OverviewTab({
    super.key,
    required this.project,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        // Description Card
        if (project.hasDescription) ...[
          _buildSectionTitle(context, 'Description'),
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: AppRadius.borderRadiusMd,
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Text(
              project.description ?? '',
              style: textTheme.bodyMedium,
            ),
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: AppSpacing.xl),
        ],

        // Stats Section
        _buildSectionTitle(context, 'Statistics'),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: LucideIcons.fileText,
                label: 'Documents',
                value: '0', // Will be replaced with actual data
                color: colorScheme.primary,
              ).animate().fadeIn(delay: 150.ms).slideX(begin: -0.1),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _StatCard(
                icon: LucideIcons.messageSquare,
                label: 'Conversations',
                value: '0', // Will be replaced with actual data
                color: colorScheme.secondary,
              ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),

        // Details Section
        _buildSectionTitle(context, 'Details'),
        const SizedBox(height: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: AppRadius.borderRadiusMd,
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Column(
            children: [
              _DetailRow(
                icon: LucideIcons.calendar,
                label: 'Created',
                value: _formatDate(project.createdAt),
              ),
              Divider(height: 1, color: colorScheme.outlineVariant),
              _DetailRow(
                icon: LucideIcons.clock,
                label: 'Last Updated',
                value: project.lastUpdatedRelative,
              ),
              Divider(height: 1, color: colorScheme.outlineVariant),
              _DetailRow(
                icon: project.isArchived ? LucideIcons.archive : LucideIcons.folderOpen,
                label: 'Status',
                value: project.isArchived ? 'Archived' : 'Active',
                valueColor: project.isArchived 
                    ? colorScheme.onSurfaceVariant 
                    : colorScheme.primary,
              ),
            ],
          ),
        ).animate().fadeIn(delay: 250.ms),
        
        const SizedBox(height: AppSpacing.xl),

        // Quick Actions
        _buildSectionTitle(context, 'Quick Actions'),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _QuickActionButton(
                icon: LucideIcons.upload,
                label: 'Upload\nDocument',
                onTap: () {
                  // TODO: Open upload dialog
                },
              ).animate().fadeIn(delay: 300.ms),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _QuickActionButton(
                icon: LucideIcons.messageSquarePlus,
                label: 'Start\nConversation',
                onTap: () {
                  // TODO: Start new conversation
                },
              ).animate().fadeIn(delay: 350.ms),
            ),
          ],
        ),
        
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: AppRadius.borderRadiusMd,
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              borderRadius: AppRadius.borderRadiusSm,
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: colorScheme.surfaceContainerHighest,
      borderRadius: AppRadius.borderRadiusMd,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.borderRadiusMd,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: AppRadius.borderRadiusMd,
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: AppRadius.borderRadiusSm,
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                label,
                style: textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
