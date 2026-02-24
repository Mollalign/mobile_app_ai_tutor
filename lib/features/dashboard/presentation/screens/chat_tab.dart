import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../app/router.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../conversations/domain/entities/entities.dart';
import '../../../conversations/presentation/providers/providers.dart';
import '../../../conversations/presentation/widgets/widgets.dart';

/// Chat tab - shows all conversations.
/// Clean, minimal design with focus on conversations.
class ChatTab extends ConsumerStatefulWidget {
  const ChatTab({super.key});

  @override
  ConsumerState<ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends ConsumerState<ChatTab> {
  final _searchController = TextEditingController();
  bool _isSearching = false;
  bool _hasLoaded = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _createNewChat() async {
    final config = await NewChatSheet.show(context);
    if (config == null || !mounted) return;

    final notifier = ref.read(createConversationNotifierProvider);
    final conversation = await notifier.createConversation(
      projectId: config.projectId,
      isSocratic: config.isSocratic,
      initialMessage: config.initialMessage,
    );

    if (conversation != null && mounted) {
      ref.read(conversationsNotifierProvider).addConversation(conversation);
      context.push('${AppRoutes.conversations}/${conversation.id}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final conversationsNotifier = ref.watch(conversationsNotifierProvider);

    return AnimatedBuilder(
      animation: conversationsNotifier,
      builder: (context, _) {
        final state = conversationsNotifier.state;

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

        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search conversations...',
                  hintStyle: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                ),
                style: textTheme.bodyMedium,
                                onChanged: (value) => setState(() {}),
              )
                            : Text(
                                'Chats',
                                style: textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
          IconButton(
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                }
              });
            },
                        icon: Icon(
                          _isSearching ? LucideIcons.x : LucideIcons.search,
          ),
                      ),
        ],
      ),
                ),

                // Content
                Expanded(
                  child: state.when(
        initial: () => const _LoadingState(),
        loading: () => const _LoadingState(),
        loaded: (conversations, total, isLoadingMore, hasMore) {
          if (conversations.isEmpty) {
            return _EmptyState(onCreateChat: _createNewChat);
          }
          return _LoadedState(
            conversations: conversations,
            isLoadingMore: isLoadingMore,
            hasMore: hasMore,
            searchQuery: _searchController.text,
            onLoadMore: () => conversationsNotifier.loadMore(),
            onRefresh: () => conversationsNotifier.loadConversations(refresh: true),
          );
        },
        error: (message) => _ErrorState(
          message: message,
          onRetry: () => conversationsNotifier.loadConversations(refresh: true),
        ),
      ),
                ),
              ],
            ),
          ),
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 72),
            child: FloatingActionButton(
              heroTag: 'chat_fab',
              onPressed: _createNewChat,
              child: const Icon(LucideIcons.plus),
            ),
          ),
        );
      },
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
    return const ShimmerConversationList();
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
    return ErrorState(message: message, onRetry: onRetry);
  }
}

class _EmptyState extends ConsumerStatefulWidget {
  final VoidCallback onCreateChat;

  const _EmptyState({required this.onCreateChat});

  @override
  ConsumerState<_EmptyState> createState() => _EmptyStateState();
}

class _EmptyStateState extends ConsumerState<_EmptyState> {
  bool _isCreating = false;

  Future<void> _startQuickChat() async {
    if (_isCreating) return;
    
    setState(() => _isCreating = true);
    
    try {
      final notifier = ref.read(createConversationNotifierProvider);
      final conversation = await notifier.createConversation(
        projectId: null,
        isSocratic: true,
        initialMessage: null,
      );

      if (conversation != null && mounted) {
        ref.read(conversationsNotifierProvider).addConversation(conversation);
        context.push('${AppRoutes.conversations}/${conversation.id}');
      }
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
      }
    }
  }

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
            const AppLogo(size: 80)
                .animate()
                .scale(duration: 400.ms, curve: Curves.elasticOut),
            const SizedBox(height: AppSpacing.lg),

            Text(
              'Start a conversation',
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: AppSpacing.sm),

            Text(
              'Ask questions, explore topics, and\nlearn with your AI tutor',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: AppSpacing.xl),

            // Quick start button
            FilledButton.icon(
              onPressed: _isCreating ? null : _startQuickChat,
              icon: _isCreating 
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.onPrimary,
                      ),
                    )
                  : const Icon(LucideIcons.sparkles, size: 18),
              label: Text(_isCreating ? 'Starting...' : 'Start Chat'),
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),

            const SizedBox(height: AppSpacing.md),

            // More options
            TextButton(
              onPressed: _isCreating ? null : widget.onCreateChat,
              child: const Text('More options'),
            ).animate().fadeIn(delay: 400.ms),
          ],
        ),
      ),
    );
  }
}

class _LoadedState extends ConsumerWidget {
  final List<Conversation> conversations;
  final bool isLoadingMore;
  final bool hasMore;
  final String searchQuery;
  final VoidCallback onLoadMore;
  final Future<void> Function() onRefresh;

  const _LoadedState({
    required this.conversations,
    required this.isLoadingMore,
    required this.hasMore,
    required this.searchQuery,
    required this.onLoadMore,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredConversations = searchQuery.isEmpty
        ? conversations
        : conversations.where((c) {
            final query = searchQuery.toLowerCase();
            return (c.title?.toLowerCase().contains(query) ?? false) ||
                (c.projectName?.toLowerCase().contains(query) ?? false);
          }).toList();

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
            left: AppSpacing.md,
            right: AppSpacing.md,
            top: AppSpacing.sm,
            bottom: 100, // Space for FAB
          ),
          itemCount: filteredConversations.length + (isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= filteredConversations.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            }

            final conversation = filteredConversations[index];
            final child = Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: ConversationCard(
                conversation: conversation,
                onTap: () {
                  context.push('${AppRoutes.conversations}/${conversation.id}');
                },
                onDelete: () => _confirmDelete(context, ref, conversation),
              ),
            );

            if (index >= 10) return child;
            return child
                .animate()
                .fadeIn(
                  delay: (50 * index).ms,
                  duration: 300.ms,
                )
                .slideY(
                  begin: 0.1,
                  end: 0,
                  delay: (50 * index).ms,
                  duration: 300.ms,
                  curve: Curves.easeOutCubic,
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
        title: const Text('Delete conversation?'),
        content: Text(
          'This will permanently delete "${conversation.displayTitle}" and all messages.',
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
                  .read(conversationsNotifierProvider)
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
