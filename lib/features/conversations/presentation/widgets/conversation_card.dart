import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../domain/entities/entities.dart';

/// Card displaying a conversation in the list.
/// Clean, minimal design inspired by modern chat apps.
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

    return Material(
      color: colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        onLongPress: onDelete,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              // Chat type indicator (colored dot)
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: conversation.isProjectChat
                      ? colorScheme.primary
                      : colorScheme.secondary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.md),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      conversation.displayTitle,
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Metadata row
                    Row(
                      children: [
                        // Chat type
                        Text(
                          conversation.isProjectChat ? 'Project' : 'Quick',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),

                        // Separator
                        Text(
                          ' · ',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),

                        // Message count
                        Text(
                          '${conversation.messageCount} messages',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),

                        // Socratic indicator
                        if (conversation.isSocratic) ...[
                          Text(
                            ' · ',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Icon(
                            LucideIcons.graduationCap,
                            size: 12,
                            color: colorScheme.tertiary,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Time
              Text(
                conversation.lastActivityRelative,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tile version for list view (more compact).
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
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: conversation.isProjectChat
              ? colorScheme.primaryContainer
              : colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(AppRadius.md),
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
      title: Text(
        conversation.displayTitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        '${conversation.messageCount} messages',
        style: textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            conversation.lastActivityRelative,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          if (conversation.isSocratic) ...[
            const SizedBox(height: 4),
            Icon(
              LucideIcons.graduationCap,
              size: 14,
              color: colorScheme.tertiary,
            ),
          ],
        ],
      ),
    );
  }
}
