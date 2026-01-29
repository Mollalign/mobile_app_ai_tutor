import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../../app/router.dart';
import '../../../../../core/constants/app_spacing.dart';
import '../../../../conversations/domain/entities/entities.dart';
import '../../../../conversations/presentation/providers/providers.dart';
import '../../../../conversations/presentation/widgets/widgets.dart';

/// Conversations tab showing chats related to this project.
class ConversationsTab extends ConsumerStatefulWidget {
  final String projectId;

  const ConversationsTab({
    super.key,
    required this.projectId,
  });

  @override
  ConsumerState<ConversationsTab> createState() => _ConversationsTabState();
}

class _ConversationsTabState extends ConsumerState<ConversationsTab> {
  Future<void> _createNewChat() async {
    // Create conversation directly for this project
    final notifier = ref.read(createConversationNotifierProvider);
    final conversation = await notifier.createConversation(
      projectId: widget.projectId,
      isSocratic: true, // Default to Socratic mode
    );

    if (conversation != null && mounted) {
      // Add to project conversations list
      ref
          .read(projectConversationsNotifierProvider(widget.projectId))
          .addConversation(conversation);
      // Navigate to chat
      context.push('${AppRoutes.conversations}/${conversation.id}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final conversationsNotifier =
        ref.watch(projectConversationsNotifierProvider(widget.projectId));

    return Scaffold(
      body: conversationsNotifier.state.when(
        initial: () => const _LoadingState(),
        loading: () => const _LoadingState(),
        loaded: (conversations, total, isLoadingMore, hasMore) {
          if (conversations.isEmpty) {
            return _EmptyState(onCreateChat: _createNewChat);
          }
          return _LoadedState(
            projectId: widget.projectId,
            conversations: conversations,
            isLoadingMore: isLoadingMore,
            hasMore: hasMore,
            onLoadMore: () => ref
                .read(projectConversationsNotifierProvider(widget.projectId))
                .loadMore(),
            onRefresh: () => ref
                .read(projectConversationsNotifierProvider(widget.projectId))
                .loadConversations(refresh: true),
          );
        },
        error: (message) => _ErrorState(
          message: message,
          onRetry: () => ref
              .read(projectConversationsNotifierProvider(widget.projectId))
              .loadConversations(refresh: true),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'conversations_fab_${widget.projectId}',
        onPressed: _createNewChat,
        icon: const Icon(LucideIcons.messageSquarePlus),
        label: const Text('New Chat'),
      ),
    );
  }
}

// ============================================================
// STATE WIDGETS
// ============================================================

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.alertCircle,
              size: 48,
              color: colorScheme.error,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Failed to load conversations',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(LucideIcons.refreshCw),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onCreateChat;

  const _EmptyState({required this.onCreateChat});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer.withAlpha(100),
                shape: BoxShape.circle,
              ),
              child: Icon(
                LucideIcons.messageSquare,
                size: 48,
                color: colorScheme.secondary,
              ),
            ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No conversations yet',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Start a conversation to ask questions\nabout your documents.',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: AppSpacing.xl),
            FilledButton.icon(
              onPressed: onCreateChat,
              icon: const Icon(LucideIcons.messageSquarePlus),
              label: const Text('Start Conversation'),
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
          ],
        ),
      ),
    );
  }
}

class _LoadedState extends ConsumerWidget {
  final String projectId;
  final List<Conversation> conversations;
  final bool isLoadingMore;
  final bool hasMore;
  final VoidCallback onLoadMore;
  final Future<void> Function() onRefresh;

  const _LoadedState({
    required this.projectId,
    required this.conversations,
    required this.isLoadingMore,
    required this.hasMore,
    required this.onLoadMore,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollEndNotification &&
              notification.metrics.extentAfter < 200 &&
              hasMore &&
              !isLoadingMore) {
            onLoadMore();
          }
          return false;
        },
        child: ListView.builder(
          padding: const EdgeInsets.only(
            top: AppSpacing.md,
            bottom: 80, // Space for FAB
          ),
          itemCount: conversations.length + (isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= conversations.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final conversation = conversations[index];
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              child: ConversationCard(
                conversation: conversation,
                onTap: () {
                  context.push('${AppRoutes.conversations}/${conversation.id}');
                },
                onDelete: () => _confirmDelete(context, ref, conversation),
              ).animate().fadeIn(delay: (50 * index).ms),
            );
          },
        ),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Conversation conversation,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(LucideIcons.alertTriangle, color: colorScheme.error),
        title: const Text('Delete Conversation?'),
        content: Text(
          'This will permanently delete "${conversation.displayTitle}" and all its messages. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await ref
                  .read(projectConversationsNotifierProvider(projectId))
                  .deleteConversation(conversation.id);
            },
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
