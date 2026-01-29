import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../domain/entities/entities.dart';

/// Message bubble widget for displaying chat messages.
class MessageBubble extends StatelessWidget {
  final Message message;
  final VoidCallback? onCopy;
  final VoidCallback? onSourceTap;

  const MessageBubble({
    super.key,
    required this.message,
    this.onCopy,
    this.onSourceTap,
  });

  @override
  Widget build(BuildContext context) {
    if (message.role.isUser) {
      return _UserBubble(message: message, onCopy: onCopy);
    } else if (message.role.isAssistant) {
      return _AssistantBubble(
        message: message,
        onCopy: onCopy,
        onSourceTap: onSourceTap,
      );
    } else {
      return _SystemBubble(message: message);
    }
  }
}

/// User message bubble (aligned right).
class _UserBubble extends StatelessWidget {
  final Message message;
  final VoidCallback? onCopy;

  const _UserBubble({
    required this.message,
    this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        margin: const EdgeInsets.only(
          left: AppSpacing.xl,
          right: AppSpacing.md,
          bottom: AppSpacing.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Message bubble
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(4),
                ),
              ),
              child: Text(
                message.content,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onPrimary,
                ),
              ),
            ),

            // Time and status
            Padding(
              padding: const EdgeInsets.only(top: 4, right: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    message.createdRelative,
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (message.isPending) ...[
                    const SizedBox(width: 4),
                    SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Assistant message bubble (aligned left).
class _AssistantBubble extends StatelessWidget {
  final Message message;
  final VoidCallback? onCopy;
  final VoidCallback? onSourceTap;

  const _AssistantBubble({
    required this.message,
    this.onCopy,
    this.onSourceTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        margin: const EdgeInsets.only(
          left: AppSpacing.md,
          right: AppSpacing.xl,
          bottom: AppSpacing.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar and label
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: colorScheme.tertiaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    LucideIcons.bot,
                    size: 16,
                    color: colorScheme.onTertiaryContainer,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'AI Tutor',
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.tertiary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),

            // Message bubble
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Content
                  if (message.isStreaming && message.content.isEmpty)
                    _StreamingIndicator()
                  else
                    SelectableText(
                      message.content,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),

                  // Sources
                  if (message.hasSources) ...[
                    const SizedBox(height: AppSpacing.sm),
                    const Divider(height: 1),
                    const SizedBox(height: AppSpacing.sm),
                    _SourcesList(
                      sources: message.sources,
                      onSourceTap: onSourceTap,
                    ),
                  ],
                ],
              ),
            ),

            // Actions
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    message.createdRelative,
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (!message.isStreaming) ...[
                    const SizedBox(width: AppSpacing.md),
                    InkWell(
                      onTap: () {
                        Clipboard.setData(
                          ClipboardData(text: message.content),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Copied to clipboard'),
                            behavior: SnackBarBehavior.floating,
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                      borderRadius: AppRadius.borderRadiusXs,
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Row(
                          children: [
                            Icon(
                              LucideIcons.copy,
                              size: 14,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Copy',
                              style: textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// System message (centered, subtle).
class _SystemBubble extends StatelessWidget {
  final Message message;

  const _SystemBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.sm,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: AppRadius.borderRadiusSm,
        ),
        child: Text(
          message.content,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

/// Streaming indicator animation.
class _StreamingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: colorScheme.tertiary,
            shape: BoxShape.circle,
          ),
        )
            .animate(
              onPlay: (controller) => controller.repeat(),
            )
            .fadeIn(delay: (index * 150).ms)
            .scale(
              begin: const Offset(0.8, 0.8),
              end: const Offset(1.2, 1.2),
              duration: 400.ms,
            )
            .then()
            .scale(
              begin: const Offset(1.2, 1.2),
              end: const Offset(0.8, 0.8),
              duration: 400.ms,
            );
      }),
    );
  }
}

/// Sources list for AI responses.
class _SourcesList extends StatelessWidget {
  final List<SourceCitation> sources;
  final VoidCallback? onSourceTap;

  const _SourcesList({
    required this.sources,
    this.onSourceTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              LucideIcons.fileText,
              size: 14,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 4),
            Text(
              'Sources',
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: sources.map((source) {
            return InkWell(
              onTap: onSourceTap,
              borderRadius: AppRadius.borderRadiusXs,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withAlpha(128),
                  borderRadius: AppRadius.borderRadiusXs,
                  border: Border.all(
                    color: colorScheme.primary.withAlpha(51),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      LucideIcons.fileText,
                      size: 12,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      source.displayText,
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
