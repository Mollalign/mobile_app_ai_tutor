import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../app/router.dart';
import '../../../../app/theme_provider.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../auth/presentation/providers/providers.dart';
import '../../../conversations/presentation/providers/providers.dart';
import '../../../conversations/presentation/widgets/widgets.dart';
import '../providers/providers.dart';
import '../../../projects/presentation/providers/providers.dart';
import '../../../knowledge/presentation/providers/knowledge_provider.dart';
import '../../../knowledge/presentation/widgets/mastery_ring.dart';
import '../../../projects/presentation/widgets/create_project_sheet.dart';
import '../../../smart_tutor/presentation/providers/smart_tutor_provider.dart';

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

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: colorScheme.primary,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            _buildAppBar(context),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const _HeroGreetingCard(),
                  const SizedBox(height: 20),
                  const FirstVisitTip(
                    tipId: 'home',
                    message:
                        'Welcome! This is your dashboard. Pull down to refresh, '
                        'and use quick actions below to get started.',
                    icon: LucideIcons.sparkles,
                  ),
                  const _QuickActionsRow(),
                  const SizedBox(height: 20),
                  const _GettingStartedCard(),
                  const SizedBox(height: 24),
                  const _StatsStrip(),
                  const SizedBox(height: 16),
                  const _SmartInsightsRow(),
                  const SizedBox(height: 24),
                  const _LearningProgressCard(),
                  const SizedBox(height: 24),
                  _SectionHeader(
                    title: 'Recent Conversations',
                    onViewAll: () {
                      ref.read(tabControllerProvider.notifier).goToChats();
                    },
                  ),
                  const SizedBox(height: 12),
                  const _RecentConversationsList(),
                  const SizedBox(height: 24),
                  _SectionHeader(
                    title: 'Your Projects',
                    onViewAll: () {
                      ref.read(tabControllerProvider.notifier).goToProjects();
                    },
                  ),
                  const SizedBox(height: 12),
                  const _ProjectsList(),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SliverAppBar(
      expandedHeight: 70,
      floating: true,
      pinned: true,
      backgroundColor: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        expandedTitleScale: 1.0,
        titlePadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        title: Row(
          children: [
            const AppLogo(size: 36),
            const SizedBox(width: 10),
            Text(
              'H2M AI',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ),
      actions: [
        const _NotificationBellButton(),
        const SizedBox(width: 4),
        _ThemeToggleButton(),
        const SizedBox(width: 12),
      ],
    );
  }
}

// ============================================================
// Hero Greeting Card
// ============================================================

class _HeroGreetingCard extends ConsumerWidget {
  const _HeroGreetingCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userName = ref.watch(
      authNotifierProvider.select((state) =>
          state.whenOrNull(authenticated: (user) => user.firstName) ??
          'Scholar'),
    );

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
            Color.lerp(colorScheme.primary, colorScheme.tertiary, 0.6)!,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withAlpha(isDark ? 60 : 80),
            blurRadius: 32,
            offset: const Offset(0, 12),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(15),
              ),
            ),
          ),
          Positioned(
            right: 20,
            bottom: -30,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(10),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(greetingIcon,
                            color: Colors.white.withAlpha(220), size: 14),
                        const SizedBox(width: 6),
                        Text(
                          greeting,
                          style: textTheme.labelMedium?.copyWith(
                            color: Colors.white.withAlpha(220),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                userName,
                style: textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'What would you like to learn today?',
                style: textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withAlpha(180),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.08, end: 0);
  }
}

// ============================================================
// Smart Insights Row
// ============================================================

class _SmartInsightsRow extends ConsumerWidget {
  const _SmartInsightsRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Expanded(
          child: _InsightPill(
            icon: LucideIcons.brainCircuit,
            label: 'Learning Style',
            color: Colors.purple,
            isDark: isDark,
            onTap: () => context.push(AppRoutes.learningStyle),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _InsightPill(
            icon: LucideIcons.lightbulb,
            label: 'Suggestions',
            color: Colors.orange,
            isDark: isDark,
            onTap: () => _showSuggestions(context, ref),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 200.ms, duration: 350.ms);
  }

  void _showSuggestions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _SuggestionsSheet(),
    );
  }
}

class _InsightPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _InsightPill({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isDark
                ? color.withAlpha(18)
                : color.withAlpha(12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withAlpha(isDark ? 25 : 20)),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              Icon(LucideIcons.chevronRight,
                  size: 14, color: colorScheme.onSurfaceVariant.withAlpha(120)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuggestionsSheet extends ConsumerWidget {
  const _SuggestionsSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestions = ref.watch(smartSuggestionsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(LucideIcons.lightbulb,
                    size: 20, color: colorScheme.primary),
                const SizedBox(width: 8),
                const Text('Smart Suggestions',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          Flexible(
            child: suggestions.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Could not load suggestions',
                    style:
                        TextStyle(color: colorScheme.onSurfaceVariant)),
              ),
              data: (data) {
                final weak = (data['weak_topics'] as List?)
                        ?.cast<Map<String, dynamic>>() ??
                    [];
                final notStarted = (data['not_started_topics'] as List?)
                        ?.cast<Map<String, dynamic>>() ??
                    [];

                if (weak.isEmpty && notStarted.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(32),
                    child: Text(
                      'No suggestions yet. Take some quizzes to get personalized recommendations!',
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return ListView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20),
                  shrinkWrap: true,
                  children: [
                    if (weak.isNotEmpty) ...[
                      Text('Topics to Review',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurfaceVariant)),
                      const SizedBox(height: 8),
                      ...weak.map((t) => _SuggestionTile(
                            topic: t,
                            colorScheme: colorScheme,
                          )),
                    ],
                    if (notStarted.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text('New Topics to Explore',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurfaceVariant)),
                      const SizedBox(height: 8),
                      ...notStarted.map((t) => _SuggestionTile(
                            topic: t,
                            colorScheme: colorScheme,
                            isNew: true,
                          )),
                    ],
                    const SizedBox(height: 24),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  final Map<String, dynamic> topic;
  final ColorScheme colorScheme;
  final bool isNew;

  const _SuggestionTile({
    required this.topic,
    required this.colorScheme,
    this.isNew = false,
  });

  @override
  Widget build(BuildContext context) {
    final name =
        topic['topic_name'] as String? ?? topic['subtopic_name'] as String? ?? '?';
    final project = topic['project_name'] as String? ?? '';
    final mastery = (topic['mastery_score'] as num?)?.toDouble();
    final action = topic['action'] as String? ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isNew ? LucideIcons.plus : LucideIcons.target,
                size: 14,
                color: isNew ? colorScheme.primary : Colors.orange,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(name,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600)),
              ),
              if (mastery != null)
                Text(
                  '${(mastery * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: mastery < 0.4 ? colorScheme.error : Colors.orange,
                  ),
                ),
            ],
          ),
          if (project.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 22),
              child: Text(project,
                  style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.onSurfaceVariant.withAlpha(160))),
            ),
          if (action.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 22),
              child: Text(action,
                  style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w500)),
            ),
        ],
      ),
    );
  }
}

// ============================================================
// Quick Actions (compact pill buttons)
// ============================================================

class _QuickActionsRow extends ConsumerWidget {
  const _QuickActionsRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: _QuickActionPill(
            icon: LucideIcons.folderPlus,
            label: 'New Project',
            gradient: [
              colorScheme.primary,
              colorScheme.primary.withAlpha(180),
            ],
            onTap: () => CreateProjectSheet.show(context),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionPill(
            icon: LucideIcons.sparkles,
            label: 'Quick Chat',
            gradient: [
              colorScheme.secondary,
              colorScheme.tertiary,
            ],
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
                ref
                    .read(conversationsNotifierProvider)
                    .addConversation(conversation);
                context
                    .push('${AppRoutes.conversations}/${conversation.id}');
              }
            },
          ),
        ),
      ],
    ).animate().fadeIn(delay: 100.ms, duration: 400.ms);
  }
}

class _QuickActionPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _QuickActionPill({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: gradient),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// Getting Started Card (shown only for new users)
// ============================================================

class _GettingStartedCard extends ConsumerWidget {
  const _GettingStartedCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsState = ref.watch(projectsNotifierProvider);
    final hasProjects = projectsState.whenOrNull(
          loaded: (projects, _, _) => projects.isNotEmpty,
        ) ??
        false;

    if (hasProjects) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final steps = [
      _StepData(
        number: '1',
        title: 'Create a project',
        subtitle: 'Organize your study materials',
        icon: LucideIcons.folderPlus,
        color: colorScheme.primary,
        onTap: () => CreateProjectSheet.show(context),
      ),
      _StepData(
        number: '2',
        title: 'Upload documents',
        subtitle: 'PDFs, notes, or slides',
        icon: LucideIcons.upload,
        color: colorScheme.secondary,
        onTap: null,
      ),
      _StepData(
        number: '3',
        title: 'Chat with AI',
        subtitle: 'Ask anything about your material',
        icon: LucideIcons.sparkles,
        color: colorScheme.tertiary,
        onTap: null,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  colorScheme.surfaceContainerHighest.withAlpha(140),
                  colorScheme.surfaceContainerHighest.withAlpha(80),
                ]
              : [
                  colorScheme.primaryContainer.withAlpha(60),
                  colorScheme.secondaryContainer.withAlpha(40),
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.primary.withAlpha(isDark ? 25 : 30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.rocket, size: 16, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Getting Started',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...steps.map((step) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _StepRow(step: step, isDark: isDark),
              )),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 400.ms);
  }
}

class _StepData {
  final String number;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _StepData({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.onTap,
  });
}

class _StepRow extends StatelessWidget {
  final _StepData step;
  final bool isDark;
  const _StepRow({required this.step, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: step.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: step.color.withAlpha(isDark ? 30 : 18),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    step.number,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: step.color,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      step.subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.onSurfaceVariant.withAlpha(160),
                      ),
                    ),
                  ],
                ),
              ),
              if (step.onTap != null)
                Icon(LucideIcons.chevronRight,
                    size: 14,
                    color: colorScheme.onSurfaceVariant.withAlpha(100)),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// Stats Strip (horizontal scrollable glassmorphic cards)
// ============================================================

class _StatsStrip extends ConsumerWidget {
  const _StatsStrip();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(dashboardStatsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    final items = <_StatData>[
      _StatData(
        icon: LucideIcons.flame,
        value: '${stats.dayStreak}',
        label: 'Day Streak',
        color: Colors.orange,
      ),
      _StatData(
        icon: LucideIcons.messageSquare,
        value: '${stats.totalConversations}',
        label: 'Conversations',
        color: colorScheme.secondary,
      ),
      _StatData(
        icon: LucideIcons.folderOpen,
        value: '${stats.totalProjects}',
        label: 'Projects',
        color: colorScheme.primary,
      ),
    ];

    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, i) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = items[index];
          return _GlassStatCard(data: item);
        },
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 400.ms);
  }
}

class _StatData {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatData({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });
}

class _GlassStatCard extends StatelessWidget {
  final _StatData data;

  const _GlassStatCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 120,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark
                ? colorScheme.surfaceContainerHighest.withAlpha(200)
                : colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: data.color.withAlpha(isDark ? 60 : 40),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: data.color.withAlpha(isDark ? 20 : 12),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: data.color.withAlpha(isDark ? 40 : 20),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(data.icon, size: 14, color: data.color),
                  ),
                  const Spacer(),
                  Text(
                    data.value,
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              Text(
                data.label,
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// Learning Progress Card (compact with mastery ring)
// ============================================================

class _LearningProgressCard extends ConsumerWidget {
  const _LearningProgressCard();

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
        final avgScore =
            (stats['avg_quiz_score'] as num?)?.toDouble() ?? 0;
        final knowledge =
            stats['knowledge'] as Map<String, dynamic>? ?? {};
        final overallMastery =
            (knowledge['overall_mastery'] as num?)?.toDouble() ?? 0;
        final topicsStudied =
            knowledge['total_topics_studied'] as int? ?? 0;
        final streak = stats['study_streak'] as int? ?? 0;

        if (quizAttempts == 0 && topicsStudied == 0) {
          return const SizedBox.shrink();
        }

        final colorScheme = Theme.of(context).colorScheme;
        final textTheme = Theme.of(context).textTheme;
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(
              title: 'Learning Progress',
              onViewAll: () => context.push(AppRoutes.progress),
            ),
            if (streak > 0) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.orange.withAlpha(isDark ? 30 : 20),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.flame,
                        size: 14, color: Colors.orange),
                    const SizedBox(width: 5),
                    Text(
                      '$streak day streak!',
                      style: textTheme.labelMedium?.copyWith(
                        color: Colors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.primaryContainer
                        .withAlpha(isDark ? 80 : 160),
                    colorScheme.tertiaryContainer
                        .withAlpha(isDark ? 50 : 100),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: colorScheme.outlineVariant
                      .withAlpha(isDark ? 30 : 60),
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
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _MiniChip(
                              icon: LucideIcons.brainCircuit,
                              value: '$quizAttempts',
                              label: 'Quizzes',
                              color: colorScheme.primary,
                              isDark: isDark,
                            ),
                            const SizedBox(width: 10),
                            _MiniChip(
                              icon: LucideIcons.target,
                              value: '${avgScore.round()}%',
                              label: 'Avg',
                              color: Colors.orange,
                              isDark: isDark,
                            ),
                            const SizedBox(width: 10),
                            _MiniChip(
                              icon: LucideIcons.bookOpen,
                              value: '$topicsStudied',
                              label: 'Topics',
                              color: Colors.green,
                              isDark: isDark,
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

class _MiniChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final bool isDark;

  const _MiniChip({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(isDark ? 25 : 15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(height: 3),
          Text(
            value,
            style: textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Section Header
// ============================================================

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onViewAll;

  const _SectionHeader({
    required this.title,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
        TextButton(
          onPressed: onViewAll,
          style: TextButton.styleFrom(
            foregroundColor: colorScheme.primary,
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            visualDensity: VisualDensity.compact,
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
              const SizedBox(width: 2),
              Icon(LucideIcons.chevronRight,
                  size: 16, color: colorScheme.primary),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================
// Recent Conversations List
// ============================================================

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
          initial: () => _buildLoading(),
          loading: () => _buildLoading(),
          loaded: (conversations, total, isLoadingMore, hasMore) {
            final recent = conversations.take(3).toList();

            if (recent.isEmpty) {
              return const EmptyStateCompact(
                icon: LucideIcons.messageCircle,
                message: 'No conversations yet',
              );
            }

            return Column(
              children: List.generate(recent.length, (index) {
                final conversation = recent[index];
                return _ItemCard(
                  title: conversation.displayTitle,
                  subtitle: conversation.projectName ??
                      (conversation.isQuickChat
                          ? 'Quick Chat'
                          : 'Project Chat'),
                  trailing: conversation.lastActivityRelative,
                  icon: conversation.isQuickChat
                      ? LucideIcons.sparkles
                      : LucideIcons.bookOpen,
                  color: conversation.isQuickChat
                      ? colorScheme.secondary
                      : colorScheme.primary,
                  onTap: () {
                    context.push(
                        '${AppRoutes.conversations}/${conversation.id}');
                  },
                )
                    .animate()
                    .fadeIn(
                      delay: Duration(milliseconds: 60 * index),
                      duration: 350.ms,
                    )
                    .slideX(begin: 0.04, end: 0);
              }),
            );
          },
          error: (_) => const EmptyStateCompact(
            icon: LucideIcons.messageCircle,
            message: 'Failed to load',
          ),
        );
      },
    );
  }

  Widget _buildLoading() {
    return Column(
      children: List.generate(3, (_) => const ShimmerHomeTile()),
    );
  }
}

// ============================================================
// Projects List
// ============================================================

class _ProjectsList extends ConsumerWidget {
  const _ProjectsList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final projectsState = ref.watch(projectsNotifierProvider);

    return projectsState.when(
      initial: () => _buildLoading(),
      loading: () => _buildLoading(),
      loaded: (projects, isLoadingMore, hasMore) {
        final recent =
            projects.where((p) => !p.isArchived).take(3).toList();

        if (recent.isEmpty) {
          return const EmptyStateCompact(
            icon: LucideIcons.folderOpen,
            message: 'No projects yet',
          );
        }

        return Column(
          children: List.generate(recent.length, (index) {
            final project = recent[index];
            return _ItemCard(
              title: project.name,
              subtitle: project.description ?? 'No description',
              trailing: project.lastUpdatedRelative,
              icon: LucideIcons.folder,
              color: colorScheme.primary,
              onTap: () {
                context.push('/projects/${project.id}');
              },
            )
                .animate()
                .fadeIn(
                  delay: Duration(milliseconds: 60 * index),
                  duration: 350.ms,
                )
                .slideX(begin: 0.04, end: 0);
          }),
        );
      },
      error: (_) => const EmptyStateCompact(
        icon: LucideIcons.folderOpen,
        message: 'Failed to load',
      ),
    );
  }

  Widget _buildLoading() {
    return Column(
      children: List.generate(2, (_) => const ShimmerHomeTile()),
    );
  }
}

// ============================================================
// Item Card (conversations & projects)
// ============================================================

class _ItemCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String trailing;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ItemCard({
    required this.title,
    required this.subtitle,
    required this.trailing,
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
        color: isDark
            ? colorScheme.surfaceContainerHighest
            : colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? colorScheme.outlineVariant.withAlpha(40)
                    : colorScheme.outlineVariant.withAlpha(100),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color.withAlpha(isDark ? 50 : 30),
                        color.withAlpha(isDark ? 30 : 15),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 20, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 12,
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
                      trailing,
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Icon(
                      LucideIcons.chevronRight,
                      size: 14,
                      color:
                          colorScheme.onSurfaceVariant.withAlpha(120),
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

// ============================================================
// Notification Bell
// ============================================================

class _NotificationBellButton extends StatefulWidget {
  const _NotificationBellButton();

  @override
  State<_NotificationBellButton> createState() =>
      _NotificationBellButtonState();
}

class _NotificationBellButtonState extends State<_NotificationBellButton> {
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchUnreadCount();
  }

  Future<void> _fetchUnreadCount() async {
    try {
      final client = ApiClient();
      final response =
          await client.get(ApiConstants.notificationsUnreadCount);
      final data = response.data as Map<String, dynamic>;
      if (mounted) {
        setState(
            () => _unreadCount = data['unread_count'] as int? ?? 0);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        IconButton(
          onPressed: () async {
            await context.push(AppRoutes.notifications);
            _fetchUnreadCount();
          },
          icon: Icon(
            LucideIcons.bell,
            color: colorScheme.onSurfaceVariant,
            size: 20,
          ),
          tooltip: 'Notifications',
          style: IconButton.styleFrom(
            backgroundColor:
                colorScheme.surfaceContainerHighest.withAlpha(180),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        if (_unreadCount > 0)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                border: Border.all(
                    color: colorScheme.surface, width: 1.5),
              ),
              constraints:
                  const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Center(
                child: Text(
                  _unreadCount > 9 ? '9+' : '$_unreadCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ============================================================
// Theme Toggle
// ============================================================

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
            turns: Tween<double>(begin: 0.5, end: 1.0)
                .animate(animation),
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
          size: 20,
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
