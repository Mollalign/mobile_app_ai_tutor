import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../app/router.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/shimmer_loading.dart';
import '../../../conversations/presentation/providers/providers.dart';

/// Recent conversations section on home tab.
/// 
/// Shows the most recent conversations with a "View All" link.
class RecentConversationsSection extends ConsumerStatefulWidget {
  const RecentConversationsSection({super.key});

  @override
  ConsumerState<RecentConversationsSection> createState() => _RecentConversationsSectionState();
}

class _RecentConversationsSectionState extends ConsumerState<RecentConversationsSection> {
  bool _hasLoaded = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final conversationsNotifier = ref.watch(conversationsNotifierProvider);

    return AnimatedBuilder(
      animation: conversationsNotifier,
      builder: (context, _) {
        final state = conversationsNotifier.state;

        // Load conversations if in initial state
        if (!_hasLoaded) {
          _hasLoaded = true;
          state.whenOrNull(
            initial: () {
              SchedulerBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  conversationsNotifier.loadConversations();
                }
              });
            },
          );
        }

        return state.when(
          initial: () => _buildLoading(context),
          loading: () => _buildLoading(context),
          loaded: (conversations, total, isLoadingMore, hasMore) {
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
                        // TODO: navigate to full conversations list
                      },
                      child: const Text('View All'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                
                if (recentConversations.isEmpty)
                  _buildEmptyState(context)
                else
                  // No animations here - they cause semantics issues when AnimatedBuilder rebuilds
                  ...recentConversations.map((conversation) {
                    return _buildConversationTile(context, conversation);
                  }),
              ],
            );
          },
          error: (_) => _buildEmptyState(context),
        );
      },
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
        ...List.generate(3, (_) => const ShimmerHomeTile()),
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
                          const SizedBox(width: AppSpacing.xs),
                          Flexible(
                            child: Text(
                              conversation.lastActivityRelative,
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                              overflow: TextOverflow.ellipsis,
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
                            Expanded(
                              child: Text(
                                conversation.projectName!,
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.primary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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
