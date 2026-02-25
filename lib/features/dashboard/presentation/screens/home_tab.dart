import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../app/router.dart';
import '../../../../app/theme_provider.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../auth/presentation/providers/providers.dart';
import '../../../conversations/presentation/providers/providers.dart';
import '../../../conversations/presentation/widgets/widgets.dart';
import '../providers/providers.dart';
import '../../../projects/presentation/providers/providers.dart';
import '../../../knowledge/presentation/providers/knowledge_provider.dart';
import '../../../knowledge/presentation/widgets/mastery_ring.dart';
import '../../../projects/presentation/widgets/create_project_sheet.dart';

/// Home tab - Modern dashboard with real data.
class HomeTab extends ConsumerStatefulWidget {
  const HomeTab({super.key});

  @override
  ConsumerState<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends ConsumerState<HomeTab> {
  Future<void> _onRefresh() async {
    await Future.wait([
      ref.read(projectsNotifierProvider.notifier).loadProjects(refresh: true),
      ref.read(conversationsNotifierProvider).loadConversations(refresh: true),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: colorScheme.primary,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 70,
              floating: true,
              pinned: true,
              backgroundColor: colorScheme.surface,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                expandedTitleScale: 1.0,
                titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                title: Row(
                  children: [
                    const AppLogo(size: 40),
                    const SizedBox(width: 12),
                    Text(
                      'AI Tutor',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                _ThemeToggleButton(),
                const SizedBox(width: 8),
              ],
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const _WelcomeCardConnected(),
                  const SizedBox(height: 24),
                  const _QuickActionsSection(),
                  const SizedBox(height: 28),
                  const _StatsSectionConnected(),
                  const SizedBox(height: 28),
                  const _LearningProgressSection(),
                  const SizedBox(height: 28),
                  _RecentSection(
                    title: 'Recent Conversations',
                    onViewAll: () {
                      ref.read(tabControllerProvider.notifier).goToChats();
                    },
                    child: const _RecentConversationsList(),
                  ),
                  const SizedBox(height: 28),
                  _RecentSection(
                    title: 'Your Projects',
                    onViewAll: () {
                      ref.read(tabControllerProvider.notifier).goToProjects();
                    },
                    child: const _ProjectsList(),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Watches only the user's first name from auth state.
class _WelcomeCardConnected extends ConsumerWidget {
  const _WelcomeCardConnected();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userName = ref.watch(
      authNotifierProvider.select((state) =>
          state.whenOrNull(authenticated: (user) => user.firstName) ??
          'Scholar'),
    );
    return _WelcomeCard(userName: userName);
  }
}

/// Welcome card with gradient and greeting.
class _WelcomeCard extends StatelessWidget {
  final String userName;

  const _WelcomeCard({required this.userName});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final hour = DateTime.now().hour;
    String greeting;
    IconData greetingIcon;

    if (hour < 12) {
      greeting = 'Good morning';
      greetingIcon = LucideIcons.sunrise;
    } else if (hour < 17) {
      greeting = 'Good afternoon';
      greetingIcon = LucideIcons.sun;
    } else {
      greeting = 'Good evening';
      greetingIcon = LucideIcons.moon;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            Color.lerp(colorScheme.primary, colorScheme.secondary, 0.5)!,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withAlpha(isDark ? 77 : 51),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                greetingIcon,
                color: Colors.white.withAlpha(204),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                greeting,
                style: textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withAlpha(204),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            userName,
            style: textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'What would you like to learn today?',
            style: textTheme.bodyMedium?.copyWith(
              color: Colors.white.withAlpha(179),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }
}

/// Quick actions section with modern cards.
class _QuickActionsSection extends ConsumerWidget {
  const _QuickActionsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _ModernActionCard(
                icon: LucideIcons.folderPlus,
                label: 'New Project',
                color: colorScheme.primary,
                onTap: () => CreateProjectSheet.show(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ModernActionCard(
                icon: LucideIcons.sparkles,
                label: 'Quick Chat',
                color: colorScheme.secondary,
                onTap: () async {
                  final config = await NewChatSheet.show(context);
                  if (config == null || !context.mounted) return;

                  final notifier = ref.read(createConversationNotifierProvider);
                  final conversation = await notifier.createConversation(
                    projectId: config.projectId,
                    isSocratic: config.isSocratic,
                    initialMessage: config.initialMessage,
                  );

                  if (conversation != null && context.mounted) {
                    ref.read(conversationsNotifierProvider).addConversation(conversation);
                    context.push('${AppRoutes.conversations}/${conversation.id}');
                  }
                },
              ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(delay: 100.ms, duration: 400.ms);
  }
}

/// Modern action card with glow effect.
class _ModernActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ModernActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark ? colorScheme.surfaceContainerHighest : colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? colorScheme.outlineVariant.withAlpha(77)
                  : colorScheme.outlineVariant,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withAlpha(isDark ? 51 : 26),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: color,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                label,
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    'Tap to start',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    LucideIcons.arrowRight,
                    size: 16,
                    color: color,
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

/// Watches dashboard stats independently.
class _StatsSectionConnected extends ConsumerWidget {
  const _StatsSectionConnected();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(dashboardStatsProvider);
    return _StatsSection(stats: stats);
  }
}

/// Stats section with real data.
class _StatsSection extends StatelessWidget {
  final DashboardStats stats;

  const _StatsSection({required this.stats});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Progress',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _ModernStatCard(
                icon: LucideIcons.flame,
                value: '${stats.dayStreak}',
                label: 'Day Streak',
                color: colorScheme.tertiary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ModernStatCard(
                icon: LucideIcons.messageSquare,
                value: '${stats.totalConversations}',
                label: 'Chats',
                color: colorScheme.secondary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ModernStatCard(
                icon: LucideIcons.folder,
                value: '${stats.totalProjects}',
                label: 'Projects',
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(delay: 200.ms, duration: 400.ms);
  }
}

/// Modern stat card with subtle background.
class _ModernStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _ModernStatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surfaceContainerHighest : colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? colorScheme.outlineVariant.withAlpha(77)
              : colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withAlpha(isDark ? 51 : 26),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 20,
              color: color,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Section with title and View All button.
class _RecentSection extends StatelessWidget {
  final String title;
  final VoidCallback onViewAll;
  final Widget child;

  const _RecentSection({
    required this.title,
    required this.onViewAll,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: onViewAll,
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'View All',
                    style: textTheme.labelMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    LucideIcons.arrowRight,
                    size: 16,
                    color: colorScheme.primary,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    ).animate().fadeIn(delay: 300.ms, duration: 400.ms);
  }
}

/// Recent conversations list with real data.
class _RecentConversationsList extends ConsumerWidget {
  const _RecentConversationsList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final conversationsNotifier = ref.watch(conversationsNotifierProvider);

    return AnimatedBuilder(
      animation: conversationsNotifier,
      builder: (context, _) {
        final state = conversationsNotifier.state;

        return state.when(
          initial: () => _buildLoading(context),
          loading: () => _buildLoading(context),
          loaded: (conversations, total, isLoadingMore, hasMore) {
            final recent = conversations.take(3).toList();

            if (recent.isEmpty) {
              return _buildEmpty(context, 'No conversations yet');
            }

            return Column(
              children: recent.map((conversation) {
                return _ConversationTile(
                  title: conversation.displayTitle,
                  subtitle: conversation.projectName ?? 
                      (conversation.isQuickChat ? 'Quick Chat' : 'Project Chat'),
                  time: conversation.lastActivityRelative,
                  icon: conversation.isQuickChat
                      ? LucideIcons.sparkles
                      : LucideIcons.bookOpen,
                  color: conversation.isQuickChat
                      ? colorScheme.secondary
                      : colorScheme.primary,
                  onTap: () {
                    context.push('${AppRoutes.conversations}/${conversation.id}');
                  },
                );
              }).toList(),
            );
          },
          error: (_) => _buildEmpty(context, 'Failed to load'),
        );
      },
    );
  }

  Widget _buildLoading(BuildContext context) {
    return Column(
      children: List.generate(3, (_) => const ShimmerHomeTile()),
    );
  }

  Widget _buildEmpty(BuildContext context, String message) {
    return EmptyStateCompact(
      icon: LucideIcons.messageCircle,
      message: message,
    );
  }
}

/// Projects list with real data.
class _ProjectsList extends ConsumerWidget {
  const _ProjectsList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final projectsState = ref.watch(projectsNotifierProvider);

    return projectsState.when(
      initial: () => _buildLoading(context),
      loading: () => _buildLoading(context),
      loaded: (projects, isLoadingMore, hasMore) {
        final recent = projects.where((p) => !p.isArchived).take(3).toList();

        if (recent.isEmpty) {
          return _buildEmpty(context, 'No projects yet');
        }

        return Column(
          children: recent.map((project) {
            return _ConversationTile(
              title: project.name,
              subtitle: project.description ?? 'No description',
              time: project.lastUpdatedRelative,
              icon: LucideIcons.folder,
              color: colorScheme.primary,
              onTap: () {
                context.push('/projects/${project.id}');
              },
            );
          }).toList(),
        );
      },
      error: (_) => _buildEmpty(context, 'Failed to load'),
    );
  }

  Widget _buildLoading(BuildContext context) {
    return Column(
      children: List.generate(2, (_) => const ShimmerHomeTile()),
    );
  }

  Widget _buildEmpty(BuildContext context, String message) {
    return EmptyStateCompact(
      icon: LucideIcons.folderOpen,
      message: message,
    );
  }
}

/// Reusable tile for conversations and projects.
class _ConversationTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String time;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ConversationTile({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: isDark ? colorScheme.surfaceContainerHighest : colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark
                    ? colorScheme.outlineVariant.withAlpha(51)
                    : colorScheme.outlineVariant,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withAlpha(isDark ? 51 : 26),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 22,
                    color: color,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      time,
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Icon(
                      LucideIcons.chevronRight,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Theme toggle button with smooth animation.
class _ThemeToggleButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    ref.watch(themeModeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return IconButton(
      onPressed: () {
        ref.read(themeModeProvider.notifier).toggleTheme(context);
      },
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return RotationTransition(
            turns: Tween<double>(begin: 0.5, end: 1.0).animate(animation),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        child: Icon(
          isDark ? LucideIcons.sun : LucideIcons.moon,
          key: ValueKey(isDark),
          color: colorScheme.onSurfaceVariant,
          size: 22,
        ),
      ),
      tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
      style: IconButton.styleFrom(
        backgroundColor: colorScheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

// ============================================================
// Learning Progress Section
// ============================================================

class _LearningProgressSection extends ConsumerWidget {
  const _LearningProgressSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(progressStatsNotifierProvider);

    return AnimatedBuilder(
      animation: notifier,
      builder: (context, _) {
        if (notifier.isLoading || notifier.stats == null) {
          return const SizedBox.shrink();
        }

        if (notifier.error != null) {
          return const SizedBox.shrink();
        }

        final stats = notifier.stats!;
        final quizAttempts = stats['total_quiz_attempts'] as int? ?? 0;
        final avgScore = (stats['avg_quiz_score'] as num?)?.toDouble() ?? 0;
        final knowledge =
            stats['knowledge'] as Map<String, dynamic>? ?? {};
        final overallMastery =
            (knowledge['overall_mastery'] as num?)?.toDouble() ?? 0;
        final topicsStudied =
            knowledge['total_topics_studied'] as int? ?? 0;

        if (quizAttempts == 0 && topicsStudied == 0) {
          return const SizedBox.shrink();
        }

        final colorScheme = Theme.of(context).colorScheme;
        final textTheme = Theme.of(context).textTheme;
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Learning Progress',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.primaryContainer
                        .withAlpha(isDark ? 80 : 150),
                    colorScheme.tertiaryContainer
                        .withAlpha(isDark ? 60 : 120),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: colorScheme.outlineVariant
                      .withAlpha(isDark ? 38 : 77),
                ),
              ),
              child: Row(
                children: [
                  MasteryRing(
                    mastery: overallMastery,
                    size: 72,
                    strokeWidth: 7,
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Overall Mastery',
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _MiniStat(
                              icon: LucideIcons.brainCircuit,
                              value: '$quizAttempts',
                              label: 'Quizzes',
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 16),
                            _MiniStat(
                              icon: LucideIcons.target,
                              value: '${avgScore.round()}%',
                              label: 'Avg Score',
                              color: Colors.orange,
                            ),
                            const SizedBox(width: 16),
                            _MiniStat(
                              icon: LucideIcons.bookOpen,
                              value: '$topicsStudied',
                              label: 'Topics',
                              color: Colors.green,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ).animate().fadeIn(delay: 300.ms, duration: 400.ms);
      },
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _MiniStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(height: 2),
        Text(
          value,
          style: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
