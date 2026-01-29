import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../domain/entities/entities.dart';

/// Card widget for displaying a project in grid view.
class ProjectGridCard extends StatelessWidget {
  final Project project;
  final VoidCallback onTap;
  final VoidCallback? onMoreTap;

  const ProjectGridCard({
    super.key,
    required this.project,
    required this.onTap,
    this.onMoreTap,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Icon + More button
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: project.isArchived
                          ? colorScheme.surfaceContainerHighest
                          : colorScheme.primaryContainer,
                      borderRadius: AppRadius.borderRadiusSm,
                    ),
                    child: Icon(
                      project.isArchived
                          ? LucideIcons.archive
                          : LucideIcons.folder,
                      size: 20,
                      color: project.isArchived
                          ? colorScheme.onSurfaceVariant
                          : colorScheme.primary,
                    ),
                  ),
                  const Spacer(),
                  if (onMoreTap != null)
                    IconButton(
                      onPressed: onMoreTap,
                      icon: const Icon(LucideIcons.moreVertical, size: 18),
                      style: IconButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(32, 32),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              // Name
              Text(
                project.name,
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: project.isArchived
                      ? colorScheme.onSurfaceVariant
                      : colorScheme.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (project.hasDescription) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  project.shortDescription ?? '',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const Spacer(),
              // Footer: Updated time
              Row(
                children: [
                  Icon(
                    LucideIcons.clock,
                    size: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      project.lastUpdatedRelative,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (project.isArchived)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Archived',
                        style: textTheme.bodySmall?.copyWith(
                          fontSize: 10,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// List tile widget for displaying a project in list view.
class ProjectListTile extends StatelessWidget {
  final Project project;
  final VoidCallback onTap;
  final VoidCallback? onMoreTap;

  const ProjectListTile({
    super.key,
    required this.project,
    required this.onTap,
    this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.borderRadiusMd,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: project.isArchived
                      ? colorScheme.surfaceContainerHighest
                      : colorScheme.primaryContainer,
                  borderRadius: AppRadius.borderRadiusMd,
                ),
                child: Icon(
                  project.isArchived
                      ? LucideIcons.archive
                      : LucideIcons.folder,
                  size: 24,
                  color: project.isArchived
                      ? colorScheme.onSurfaceVariant
                      : colorScheme.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            project.name,
                            style: textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: project.isArchived
                                  ? colorScheme.onSurfaceVariant
                                  : colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (project.isArchived)
                          Container(
                            margin: const EdgeInsets.only(left: AppSpacing.sm),
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Archived',
                              style: textTheme.bodySmall?.copyWith(
                                fontSize: 10,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (project.hasDescription) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        project.shortDescription ?? '',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Updated ${project.lastUpdatedRelative}',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              // More button
              if (onMoreTap != null)
                IconButton(
                  onPressed: onMoreTap,
                  icon: const Icon(LucideIcons.moreVertical, size: 18),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
