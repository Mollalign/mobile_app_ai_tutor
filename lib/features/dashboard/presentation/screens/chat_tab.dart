import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../app/router.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../conversations/domain/entities/entities.dart';
import '../../../conversations/presentation/providers/providers.dart';
import '../../../conversations/presentation/widgets/widgets.dart';

class ChatTab extends ConsumerStatefulWidget {
  const ChatTab({super.key});

  @override
  ConsumerState<ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends ConsumerState<ChatTab> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
          backgroundColor: colorScheme.surface,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight: 70,
                floating: true,
                pinned: true,
                backgroundColor: colorScheme.surface,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  expandedTitleScale: 1.0,
                  titlePadding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                  title: Text(
                    'Chats',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
              ),

              // Search bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? colorScheme.surfaceContainerHighest
                          : colorScheme.surfaceContainerHighest
                              .withAlpha(120),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colorScheme.outlineVariant
                            .withAlpha(isDark ? 40 : 80),
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) =>
                          setState(() => _searchQuery = v),
                      decoration: InputDecoration(
                        hintText: 'Search conversations...',
                        prefixIcon: Icon(LucideIcons.search,
                            size: 18,
                            color: colorScheme.onSurfaceVariant),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(LucideIcons.x,
                                    size: 16,
                                    color: colorScheme
                                        .onSurfaceVariant),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(
                                      () => _searchQuery = '');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ).animate().fadeIn(duration: 300.ms),
                ),
              ),

              // Tip
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: FirstVisitTip(
                    tipId: 'chat',
                    message:
                        'Start a new chat to ask questions. '
                        'The AI adapts to your level and uses your uploaded materials.',
                    icon: LucideIcons.messageCircle,
                  ),
                ),
              ),

              // Content
              state.when(
                initial: () => const SliverFillRemaining(
                    child: ShimmerConversationList()),
                loading: () => const SliverFillRemaining(
                    child: ShimmerConversationList()),
                loaded: (conversations, total, isLoadingMore,
                    hasMore) {
                  if (conversations.isEmpty) {
                    return SliverFillRemaining(
                      child:
                          _EmptyState(onCreateChat: _createNewChat),
                    );
                  }
                  return _GroupedContent(
                    conversations: conversations,
                    searchQuery: _searchQuery,
                    onRefresh: () => conversationsNotifier
                        .loadConversations(refresh: true),
                  );
                },
                error: (message) => SliverFillRemaining(
                  child: ErrorState(
                      message: message,
                      onRetry: () => conversationsNotifier
                          .loadConversations(refresh: true)),
                ),
              ),
            ],
          ),
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 72),
            child: FloatingActionButton(
              heroTag: 'chat_fab',
              onPressed: () {
                HapticFeedback.lightImpact();
                _createNewChat();
              },
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              elevation: 4,
              child: const Icon(LucideIcons.plus, size: 24),
            ),
          ),
        );
      },
    );
  }
}

// ============================================================
// Grouped Content
// ============================================================

class _GroupedContent extends ConsumerWidget {
  final List<Conversation> conversations;
  final String searchQuery;
  final Future<void> Function() onRefresh;

  const _GroupedContent({
    required this.conversations,
    required this.searchQuery,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtered = searchQuery.isEmpty
        ? conversations
        : conversations.where((c) {
            final q = searchQuery.toLowerCase();
            return (c.title?.toLowerCase().contains(q) ?? false) ||
                (c.projectName?.toLowerCase().contains(q) ?? false) ||
                (c.displayTitle.toLowerCase().contains(q));
          }).toList();

    if (filtered.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.searchX,
                  size: 48,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant
                      .withAlpha(120)),
              const SizedBox(height: 12),
              Text(
                'No conversations match "$searchQuery"',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    // Group by project
    final quickChats =
        filtered.where((c) => c.isQuickChat).toList();
    final projectGroups = <String, List<Conversation>>{};
    final projectNames = <String, String>{};

    for (final c in filtered) {
      if (c.isProjectChat && c.projectId != null) {
        projectGroups.putIfAbsent(c.projectId!, () => []).add(c);
        projectNames[c.projectId!] =
            c.projectName ?? 'Unknown Project';
      }
    }

    // Sort project groups by most recent activity
    final sortedProjectIds = projectGroups.keys.toList()
      ..sort((a, b) {
        final aTime = projectGroups[a]!
            .map((c) => c.lastMessageAt ?? c.updatedAt)
            .reduce((a, b) => a.isAfter(b) ? a : b);
        final bTime = projectGroups[b]!
            .map((c) => c.lastMessageAt ?? c.updatedAt)
            .reduce((a, b) => a.isAfter(b) ? a : b);
        return bTime.compareTo(aTime);
      });

    final widgets = <Widget>[];
    int animIndex = 0;

    // Quick Chats section
    if (quickChats.isNotEmpty) {
      widgets.add(_GroupHeader(
        icon: LucideIcons.sparkles,
        title: 'Quick Chats',
        count: quickChats.length,
        color: Theme.of(context).colorScheme.secondary,
      ));
      for (final c in quickChats) {
        final idx = animIndex++;
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ConversationCard(
              conversation: c,
              onTap: () => context
                  .push('${AppRoutes.conversations}/${c.id}'),
              onDelete: () =>
                  _confirmDelete(context, ref, c),
            ),
          )
              .animate()
              .fadeIn(
                delay: Duration(
                    milliseconds: idx < 10 ? 40 * idx : 0),
                duration: 300.ms,
              )
              .slideX(begin: 0.03, end: 0),
        );
      }
    }

    // Project groups
    for (final projectId in sortedProjectIds) {
      final chats = projectGroups[projectId]!;
      final name = projectNames[projectId]!;

      widgets.add(const SizedBox(height: 8));
      widgets.add(_GroupHeader(
        icon: LucideIcons.folder,
        title: name,
        count: chats.length,
        color: _projectAccent(name, Theme.of(context).colorScheme),
      ));
      for (final c in chats) {
        final idx = animIndex++;
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ConversationCard(
              conversation: c,
              onTap: () => context
                  .push('${AppRoutes.conversations}/${c.id}'),
              onDelete: () =>
                  _confirmDelete(context, ref, c),
            ),
          )
              .animate()
              .fadeIn(
                delay: Duration(
                    milliseconds: idx < 10 ? 40 * idx : 0),
                duration: 300.ms,
              )
              .slideX(begin: 0.03, end: 0),
        );
      }
    }

    widgets.add(const SizedBox(height: 100));

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => widgets[index],
          childCount: widgets.length,
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
        icon: Icon(LucideIcons.alertTriangle,
            color: colorScheme.error),
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

Color _projectAccent(String name, ColorScheme cs) {
  final hash = name.hashCode;
  final colors = [
    cs.primary,
    cs.secondary,
    cs.tertiary,
    Colors.orange,
    Colors.teal,
    Colors.indigo,
    Colors.pink,
    Colors.cyan,
  ];
  return colors[hash.abs() % colors.length];
}

// ============================================================
// Group Header
// ============================================================

class _GroupHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final int count;
  final Color color;

  const _GroupHeader({
    required this.icon,
    required this.title,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 10),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color.withAlpha(isDark ? 30 : 18),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 14, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: colorScheme.onSurfaceVariant
                  .withAlpha(isDark ? 20 : 12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Empty State
// ============================================================

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
        ref
            .read(conversationsNotifierProvider)
            .addConversation(conversation);
        context.push(
            '${AppRoutes.conversations}/${conversation.id}');
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
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AppLogo(size: 80)
                .animate()
                .scale(duration: 400.ms, curve: Curves.elasticOut),
            const SizedBox(height: 24),
            Text(
              'Start a conversation',
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 8),
            Text(
              'Ask questions, explore topics, and\nlearn with your AI tutor',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 28),
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
              label: Text(
                  _isCreating ? 'Starting...' : 'Start Chat'),
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
            const SizedBox(height: 12),
            TextButton(
              onPressed:
                  _isCreating ? null : widget.onCreateChat,
              child: const Text('More options'),
            ).animate().fadeIn(delay: 400.ms),
          ],
        ),
      ),
    );
  }
}
