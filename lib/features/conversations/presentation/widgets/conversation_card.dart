import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../domain/entities/entities.dart';

/// Card displaying a conversation in the list.
class ConversationCard extends StatelessWidget {
  final Conversation conversation;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const ConversationCard({
    super.key,
    required this.conversation,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.borderRadiusMd,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: conversation.isProjectChat
                      ? colorScheme.primaryContainer
                      : colorScheme.secondaryContainer,
                  borderRadius: AppRadius.borderRadiusSm,
                ),
                child: Icon(
                  conversation.isProjectChat
                      ? LucideIcons.bookOpen
                      : LucideIcons.sparkles,
                  color: conversation.isProjectChat
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSecondaryContainer,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and time
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            conversation.displayTitle,
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          conversation.lastActivityRelative,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),

                    // Chat type badge and message count
                    Row(
                      children: [
                        // Chat type badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: conversation.isProjectChat
                                ? colorScheme.primaryContainer.withAlpha(128)
                                : colorScheme.secondaryContainer.withAlpha(128),
                            borderRadius: AppRadius.borderRadiusXs,
                          ),
                          child: Text(
                            conversation.chatType.displayName,
                            style: textTheme.labelSmall?.copyWith(
                              color: conversation.isProjectChat
                                  ? colorScheme.primary
                                  : colorScheme.secondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),

                        // Socratic mode indicator
                        if (conversation.isSocratic) ...[
                          Icon(
                            LucideIcons.graduationCap,
                            size: 14,
                            color: colorScheme.tertiary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Socratic',
                            style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.tertiary,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                        ],

                        // Message count
                        Icon(
                          LucideIcons.messageSquare,
                          size: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${conversation.messageCount}',
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),

                    // Project name (if project chat)
                    if (conversation.isProjectChat &&
                        conversation.projectName != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          Icon(
                            LucideIcons.folder,
                            size: 14,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              conversation.projectName!,
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // More options
              if (onDelete != null) ...[
                const SizedBox(width: AppSpacing.sm),
                IconButton(
                  onPressed: onDelete,
                  icon: Icon(
                    LucideIcons.trash2,
                    size: 18,
                    color: colorScheme.error,
                  ),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Tile version for list view.
class ConversationListTile extends StatelessWidget {
  final Conversation conversation;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const ConversationListTile({
    super.key,
    required this.conversation,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ListTile(
      onTap: onTap,
      onLongPress: onLongPress,
      leading: CircleAvatar(
        backgroundColor: conversation.isProjectChat
            ? colorScheme.primaryContainer
            : colorScheme.secondaryContainer,
        child: Icon(
          conversation.isProjectChat
              ? LucideIcons.bookOpen
              : LucideIcons.sparkles,
          color: conversation.isProjectChat
              ? colorScheme.onPrimaryContainer
              : colorScheme.onSecondaryContainer,
          size: 20,
        ),
      ),
      title: Text(
        conversation.displayTitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Row(
        children: [
          Text(
            conversation.chatType.displayName,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.primary,
            ),
          ),
          Text(
            ' • ${conversation.messageCount} messages',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      trailing: Text(
        conversation.lastActivityRelative,
        style: textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
