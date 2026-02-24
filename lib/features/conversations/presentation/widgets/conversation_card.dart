import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../domain/entities/entities.dart';

/// Card displaying a conversation in the list.
/// Modern design with avatar, swipe-to-delete, and accent gradient.
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget card = _ConversationCardContent(
      conversation: conversation,
      onTap: onTap,
      onDelete: onDelete,
    );

    if (onDelete != null) {
      card = Dismissible(
        key: ValueKey(conversation.id),
        direction: DismissDirection.endToStart,
        confirmDismiss: (_) async {
          onDelete!();
          return false;
        },
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          decoration: BoxDecoration(
            color: colorScheme.error.withAlpha(isDark ? 51 : 26),
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Icon(
            LucideIcons.trash2,
            color: colorScheme.error,
            size: 22,
          ),
        ),
        child: card,
      );
    }

    return card;
  }
}

class _ConversationCardContent extends StatelessWidget {
  final Conversation conversation;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const _ConversationCardContent({
    required this.conversation,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final accentColor = conversation.isProjectChat
        ? colorScheme.primary
        : colorScheme.secondary;

    return Material(
      color: isDark
          ? colorScheme.surfaceContainerHighest
          : colorScheme.surface,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        onLongPress: onDelete,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: isDark
                  ? colorScheme.outlineVariant.withAlpha(38)
                  : colorScheme.outlineVariant,
            ),
          ),
          child: Row(
            children: [
              // Chat type avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      accentColor.withAlpha(isDark ? 51 : 26),
                      accentColor.withAlpha(isDark ? 26 : 13),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  conversation.isProjectChat
                      ? LucideIcons.bookOpen
                      : LucideIcons.sparkles,
                  size: 22,
                  color: accentColor,
                ),
              ),
              const SizedBox(width: 14),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      conversation.displayTitle,
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (conversation.lastMessagePreview != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        conversation.lastMessagePreview!,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant.withAlpha(179),
                          height: 1.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          conversation.isProjectChat ? 'Project' : 'Quick',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          ' · ${conversation.messageCount} msgs',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (conversation.isSocratic) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.tertiary.withAlpha(isDark ? 38 : 26),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  LucideIcons.graduationCap,
                                  size: 10,
                                  color: colorScheme.tertiary,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  'Socratic',
                                  style: textTheme.labelSmall?.copyWith(
                                    fontSize: 9,
                                    color: colorScheme.tertiary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Time + chevron
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    conversation.lastActivityRelative,
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Icon(
                    LucideIcons.chevronRight,
                    size: 16,
                    color: colorScheme.onSurfaceVariant.withAlpha(128),
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
