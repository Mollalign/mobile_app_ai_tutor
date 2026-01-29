import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../app/router.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../conversations/presentation/providers/providers.dart';

/// Recent conversations section on home tab.
/// 
/// Shows the most recent conversations with a "View All" link.
class RecentConversationsSection extends ConsumerWidget {
  const RecentConversationsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final conversationsNotifier = ref.watch(conversationsNotifierProvider);

    return conversationsNotifier.state.when(
      initial: () => _buildLoading(context),
      loading: () => _buildLoading(context),
      loaded: (conversations, total, isLoadingMore, hasMore) {
        // Show only the 3 most recent
        final recentConversations = conversations.take(3).toList();

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
                    // Navigate to chat tab (index 2 in MainShell)
                    // We can't directly change tab index, so navigate to chat route
                    // For now, just show a message or navigate to conversations list
                    // TODO: Add a way to switch tabs programmatically
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            
            if (recentConversations.isEmpty)
              _buildEmptyState(context)
            else
              ...recentConversations.asMap().entries.map((entry) {
                final index = entry.key;
                final conversation = entry.value;
                return _buildConversationTile(context, conversation)
                    .animate()
                    .fadeIn(delay: (100 * index).ms)
                    .slideX(begin: 0.05, end: 0);
              }),
          ],
        );
      },
      error: (_) => _buildEmptyState(context),
    );
  }

  Widget _buildLoading(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Conversations',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        const Center(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: CircularProgressIndicator(),
          ),
        ),
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

  Widget _buildConversationTile(BuildContext context, conversation) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: AppRadius.borderRadiusMd,
        child: InkWell(
          onTap: () {
            context.push('${AppRoutes.conversations}/${conversation.id}');
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
                    color: conversation.isQuickChat
                        ? colorScheme.secondaryContainer
                        : colorScheme.primaryContainer,
                    borderRadius: AppRadius.borderRadiusSm,
                  ),
                  child: Icon(
                    conversation.isQuickChat
                        ? LucideIcons.sparkles
                        : LucideIcons.messageSquare,
                    size: 18,
                    color: conversation.isQuickChat
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
                              conversation.displayTitle,
                              style: textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            conversation.lastActivityRelative,
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      if (conversation.projectName != null) ...[
                        Row(
                          children: [
                            Icon(
                              LucideIcons.folder,
                              size: 12,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              conversation.projectName!,
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                      ],
                      Text(
                        conversation.messageCount > 0
                            ? '${conversation.messageCount} message${conversation.messageCount == 1 ? '' : 's'}'
                            : 'No messages yet',
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
