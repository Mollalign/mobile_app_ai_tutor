import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_spacing.dart';
import '../providers/document_state.dart';

/// Card showing upload progress.
class UploadProgressCard extends StatelessWidget {
  final UploadState uploadState;
  final VoidCallback? onCancel;
  final VoidCallback? onDismiss;

  const UploadProgressCard({
    super.key,
    required this.uploadState,
    this.onCancel,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: AppRadius.borderRadiusMd,
        border: Border.all(
          color: uploadState.error != null
              ? colorScheme.error.withAlpha(100)
              : colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: _getStatusColor(colorScheme).withAlpha(25),
                  borderRadius: AppRadius.borderRadiusSm,
                ),
                child: Icon(
                  _getStatusIcon(),
                  size: 18,
                  color: _getStatusColor(colorScheme),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      uploadState.filename,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      _getStatusText(),
                      style: textTheme.bodySmall?.copyWith(
                        color: uploadState.error != null
                            ? colorScheme.error
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Action button
              if (uploadState.isUploading)
                IconButton(
                  onPressed: onCancel,
                  icon: Icon(
                    LucideIcons.x,
                    size: 18,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  style: IconButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(32, 32),
                  ),
                )
              else if (uploadState.isComplete || uploadState.error != null)
                IconButton(
                  onPressed: onDismiss,
                  icon: Icon(
                    LucideIcons.x,
                    size: 18,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  style: IconButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(32, 32),
                  ),
                ),
            ],
          ),
          
          // Progress bar
          if (uploadState.isUploading) ...[
            const SizedBox(height: AppSpacing.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: uploadState.progress,
                backgroundColor: colorScheme.surfaceContainerLow,
                valueColor: AlwaysStoppedAnimation(colorScheme.primary),
                minHeight: 4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getStatusIcon() {
    if (uploadState.error != null) {
      return LucideIcons.alertCircle;
    }
    if (uploadState.isComplete) {
      return LucideIcons.checkCircle2;
    }
    return LucideIcons.upload;
  }

  Color _getStatusColor(ColorScheme colorScheme) {
    if (uploadState.error != null) {
      return colorScheme.error;
    }
    if (uploadState.isComplete) {
      return colorScheme.primary;
    }
    return colorScheme.tertiary;
  }

  String _getStatusText() {
    if (uploadState.error != null) {
      return uploadState.error!;
    }
    if (uploadState.isComplete) {
      return 'Upload complete';
    }
    final percent = (uploadState.progress * 100).toInt();
    return 'Uploading... $percent%';
  }
}
