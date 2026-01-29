import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../domain/entities/entities.dart';

/// Card widget for displaying a document.
class DocumentCard extends StatelessWidget {
  final Document document;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onReprocess;
  final VoidCallback? onDownload;

  const DocumentCard({
    super.key,
    required this.document,
    this.onTap,
    this.onDelete,
    this.onReprocess,
    this.onDownload,
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
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: AppRadius.borderRadiusMd,
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Row(
            children: [
              // File type icon
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: _getFileTypeColor(colorScheme).withAlpha(25),
                  borderRadius: AppRadius.borderRadiusSm,
                ),
                child: Icon(
                  _getFileTypeIcon(),
                  size: 24,
                  color: _getFileTypeColor(colorScheme),
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
                            document.displayName,
                            style: textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _buildStatusBadge(context),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Text(
                          document.fileType.displayName,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        _buildDot(context),
                        Text(
                          document.fileSizeDisplay,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (document.isReady) ...[
                          _buildDot(context),
                          Text(
                            '${document.chunkCount} chunks',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      document.createdRelative,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Actions menu
              PopupMenuButton<String>(
                icon: Icon(
                  LucideIcons.moreVertical,
                  color: colorScheme.onSurfaceVariant,
                ),
                onSelected: (value) {
                  switch (value) {
                    case 'download':
                      onDownload?.call();
                      break;
                    case 'reprocess':
                      onReprocess?.call();
                      break;
                    case 'delete':
                      onDelete?.call();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  if (document.isReady)
                    const PopupMenuItem(
                      value: 'download',
                      child: Row(
                        children: [
                          Icon(LucideIcons.download, size: 18),
                          SizedBox(width: AppSpacing.sm),
                          Text('Download'),
                        ],
                      ),
                    ),
                  if (document.hasFailed)
                    const PopupMenuItem(
                      value: 'reprocess',
                      child: Row(
                        children: [
                          Icon(LucideIcons.refreshCw, size: 18),
                          SizedBox(width: AppSpacing.sm),
                          Text('Reprocess'),
                        ],
                      ),
                    ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          LucideIcons.trash2,
                          size: 18,
                          color: colorScheme.error,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'Delete',
                          style: TextStyle(color: colorScheme.error),
                        ),
                      ],
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

  Widget _buildStatusBadge(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final (color, bgColor, icon) = switch (document.status) {
      DocumentStatus.ready => (
          colorScheme.primary,
          colorScheme.primaryContainer,
          LucideIcons.checkCircle2,
        ),
      DocumentStatus.pending || DocumentStatus.processing => (
          colorScheme.tertiary,
          colorScheme.tertiaryContainer,
          LucideIcons.loader,
        ),
      DocumentStatus.failed => (
          colorScheme.error,
          colorScheme.errorContainer,
          LucideIcons.alertCircle,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            document.status.displayName,
            style: textTheme.bodySmall?.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: Text(
        '•',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  IconData _getFileTypeIcon() {
    return switch (document.fileType) {
      FileType.pdf => LucideIcons.fileText,
      FileType.docx => LucideIcons.fileType,
      FileType.pptx => LucideIcons.presentation,
      FileType.txt => LucideIcons.fileCode,
    };
  }

  Color _getFileTypeColor(ColorScheme colorScheme) {
    return switch (document.fileType) {
      FileType.pdf => Colors.red.shade600,
      FileType.docx => Colors.blue.shade600,
      FileType.pptx => Colors.orange.shade600,
      FileType.txt => colorScheme.primary,
    };
  }
}
