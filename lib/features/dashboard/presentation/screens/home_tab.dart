import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../app/router.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../auth/presentation/providers/providers.dart';
import '../../../conversations/presentation/providers/providers.dart';
import '../../../conversations/presentation/widgets/widgets.dart';
import '../providers/providers.dart';
import '../widgets/quick_action_card.dart';
import '../widgets/recent_conversations_section.dart';
import '../widgets/projects_overview_section.dart';
import '../widgets/stats_card.dart';
import '../../../projects/presentation/widgets/create_project_sheet.dart';

/// Home tab - the main dashboard view.
/// 
/// Shows:
/// - Welcome header with user name
/// - Quick action buttons (New Project, Quick Chat)
/// - Learning stats (real data)
/// - Recent conversations (real data)
/// - Projects overview (real data)
class HomeTab extends ConsumerWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final stats = ref.watch(dashboardStatsProvider);

    final user = authState.whenOrNull(
      authenticated: (user) => user,
    );

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Custom App Bar
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: colorScheme.surface,
            surfaceTintColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              expandedTitleScale: 1.0,
              titlePadding: const EdgeInsets.only(
                left: AppSpacing.lg,
                bottom: AppSpacing.md,
              ),
              title: Row(
                children: [
                  // App logo
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: AppRadius.borderRadiusMd,
                    ),
                    child: Icon(
                      LucideIcons.graduationCap,
                      size: 20,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'AI Tutor',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  // TODO: Notifications
                },
                icon: const Icon(LucideIcons.bell),
              ),
              const SizedBox(width: AppSpacing.xs),
            ],
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Welcome Section
                _buildWelcomeSection(context, user?.firstName ?? 'Scholar'),
                
                const SizedBox(height: AppSpacing.xl),

                // Quick Actions
                _buildQuickActionsSection(context, ref),

                const SizedBox(height: AppSpacing.xl),

                // Stats Cards
                _buildStatsSection(context, stats),

                const SizedBox(height: AppSpacing.xl),

                // Recent Conversations
                const RecentConversationsSection(),

                const SizedBox(height: AppSpacing.xl),

                // Projects Overview
                const ProjectsOverviewSection(),

                // Bottom padding for safe area
                const SizedBox(height: AppSpacing.xl),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context, String userName) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Get greeting based on time of day
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
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            colorScheme.primary.withAlpha(200),
          ],
        ),
        borderRadius: AppRadius.borderRadiusLg,
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withAlpha(50),
            blurRadius: 20,
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
                color: Colors.white.withAlpha(200),
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                greeting,
                style: textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withAlpha(200),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            userName,
            style: textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Ready to continue your learning journey?',
            style: textTheme.bodyMedium?.copyWith(
              color: Colors.white.withAlpha(180),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildQuickActionsSection(BuildContext context, WidgetRef ref) {
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
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: QuickActionCard(
                icon: LucideIcons.folderPlus,
                label: 'New Project',
                description: 'Create a study project',
                color: colorScheme.primary,
                onTap: () => CreateProjectSheet.show(context),
              ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.1, end: 0),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: QuickActionCard(
                icon: LucideIcons.sparkles,
                label: 'Quick Chat',
                description: 'Ask AI anything',
                color: colorScheme.secondary,
                onTap: () async {
                  // Create a quick chat conversation
                  final config = await NewChatSheet.show(context);
                  if (config == null || !context.mounted) return;

                  final notifier = ref.read(createConversationNotifierProvider);
                  final conversation = await notifier.createConversation(
                    projectId: config.projectId,
                    isSocratic: config.isSocratic,
                    initialMessage: config.initialMessage,
                  );

                  if (conversation != null && context.mounted) {
                    // Add to conversations list
                    ref.read(conversationsNotifierProvider).addConversation(conversation);
                    // Navigate to chat
                    context.push('${AppRoutes.conversations}/${conversation.id}');
                  }
                },
              ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1, end: 0),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsSection(BuildContext context, DashboardStats stats) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Your Progress',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: View detailed stats
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: StatsCard(
                icon: LucideIcons.flame,
                label: 'Day Streak',
                value: stats.dayStreak > 0 ? '${stats.dayStreak}' : '0',
                color: colorScheme.tertiary,
              ).animate().fadeIn(delay: 150.ms).scale(begin: const Offset(0.9, 0.9)),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: StatsCard(
                icon: LucideIcons.messageSquare,
                label: 'Chats',
                value: '${stats.totalConversations}',
                color: colorScheme.secondary,
              ).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.9, 0.9)),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: StatsCard(
                icon: LucideIcons.fileText,
                label: 'Documents',
                value: '${stats.totalDocuments}',
                color: colorScheme.primary,
              ).animate().fadeIn(delay: 250.ms).scale(begin: const Offset(0.9, 0.9)),
            ),
          ],
        ),
      ],
    );
  }
}
