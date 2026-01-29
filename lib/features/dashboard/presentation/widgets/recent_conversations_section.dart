import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_spacing.dart';

/// Recent conversations section on home tab.
/// 
/// Shows the most recent conversations with a "View All" link.
/// Currently shows placeholder data - will be connected to API in Feature 4.
class RecentConversationsSection extends StatelessWidget {
  const RecentConversationsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // Placeholder data - will be replaced with actual API data
    final conversations = [
      _ConversationItem(
        title: 'Understanding Calculus Derivatives',
        projectName: 'Math 101',
        lastMessage: 'The power rule states that...',
        timeAgo: '2 hours ago',
        isQuickChat: false,
      ),
      _ConversationItem(
        title: 'Quick Question',
        projectName: null,
        lastMessage: 'What is the difference between...',
        timeAgo: '5 hours ago',
        isQuickChat: true,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Conversations',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: Navigate to chat tab
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        
        if (conversations.isEmpty)
          _buildEmptyState(context)
        else
          ...conversations.asMap().entries.map((entry) {
            final index = entry.key;
            final conversation = entry.value;
            return _buildConversationTile(context, conversation)
                .animate()
                .fadeIn(delay: (100 * index).ms)
                .slideX(begin: 0.05, end: 0);
          }),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: AppRadius.borderRadiusMd,
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(
            LucideIcons.messageCircle,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'No conversations yet. Start chatting with your AI tutor!',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationTile(BuildContext context, _ConversationItem item) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: AppRadius.borderRadiusMd,
        child: InkWell(
          onTap: () {
            // TODO: Navigate to conversation
          },
          borderRadius: AppRadius.borderRadiusMd,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              borderRadius: AppRadius.borderRadiusMd,
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Row(
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: item.isQuickChat
                        ? colorScheme.secondaryContainer
                        : colorScheme.primaryContainer,
                    borderRadius: AppRadius.borderRadiusSm,
                  ),
                  child: Icon(
                    item.isQuickChat
                        ? LucideIcons.sparkles
                        : LucideIcons.messageSquare,
                    size: 18,
                    color: item.isQuickChat
                        ? colorScheme.secondary
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
                              item.title,
                              style: textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            item.timeAgo,
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      if (item.projectName != null) ...[
                        Row(
                          children: [
                            Icon(
                              LucideIcons.folder,
                              size: 12,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              item.projectName!,
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                      ],
                      Text(
                        item.lastMessage,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Icon(
                  LucideIcons.chevronRight,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ConversationItem {
  final String title;
  final String? projectName;
  final String lastMessage;
  final String timeAgo;
  final bool isQuickChat;

  const _ConversationItem({
    required this.title,
    required this.projectName,
    required this.lastMessage,
    required this.timeAgo,
    required this.isQuickChat,
  });
}
