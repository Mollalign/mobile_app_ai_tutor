import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../projects/presentation/providers/providers.dart';
import '../../../projects/presentation/widgets/project_card.dart';
import '../../../projects/presentation/widgets/create_project_sheet.dart';
import '../../../projects/presentation/widgets/project_actions_sheet.dart';

/// Projects tab - shows all user projects.
/// 
/// Features:
/// - Grid/List view toggle
/// - Create project button
/// - Pull to refresh
/// - Loading states
class ProjectsTab extends ConsumerWidget {
  const ProjectsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsState = ref.watch(projectsNotifierProvider);
    final isGridView = ref.watch(projectsViewModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects'),
        actions: [
          // View toggle
          IconButton(
            onPressed: () {
              ref.read(projectsViewModeProvider.notifier).toggle();
            },
            icon: Icon(
              isGridView ? LucideIcons.list : LucideIcons.layoutGrid,
            ),
            tooltip: isGridView ? 'List view' : 'Grid view',
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: projectsState.when(
        initial: () => const _LoadingState(),
        loading: () => const _LoadingState(),
        loaded: (projects, isLoadingMore, hasMore) {
          if (projects.isEmpty) {
            return _EmptyState(
              onCreateProject: () => CreateProjectSheet.show(context),
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref
                .read(projectsNotifierProvider.notifier)
                .loadProjects(refresh: true),
            child: isGridView
                ? _ProjectsGridView(
                    projects: projects,
                    isLoadingMore: isLoadingMore,
                    hasMore: hasMore,
                    onLoadMore: () => ref
                        .read(projectsNotifierProvider.notifier)
                        .loadMore(),
                  )
                : _ProjectsListView(
                    projects: projects,
                    isLoadingMore: isLoadingMore,
                    hasMore: hasMore,
                    onLoadMore: () => ref
                        .read(projectsNotifierProvider.notifier)
                        .loadMore(),
                  ),
          );
        },
        error: (message) => _ErrorState(
          message: message,
          onRetry: () => ref
              .read(projectsNotifierProvider.notifier)
              .loadProjects(refresh: true),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => CreateProjectSheet.show(context),
        icon: const Icon(LucideIcons.plus),
        label: const Text('New Project'),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: 1.0,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: AppRadius.borderRadiusMd,
        ),
      ).animate(onPlay: (c) => c.repeat())
          .shimmer(duration: 1500.ms, color: colorScheme.surface),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onCreateProject;

  const _EmptyState({required this.onCreateProject});

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
                color: colorScheme.primaryContainer.withAlpha(100),
                shape: BoxShape.circle,
              ),
              child: Icon(
                LucideIcons.folderOpen,
                size: 48,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No projects yet',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Create your first project to organize\nyour study materials and conversations.',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton.icon(
              onPressed: onCreateProject,
              icon: const Icon(LucideIcons.plus),
              label: const Text('Create Project'),
            ),
          ],
        ).animate().fadeIn().slideY(begin: 0.1, end: 0),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

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
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                LucideIcons.alertCircle,
                size: 48,
                color: colorScheme.error,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Something went wrong',
              style: textTheme.titleLarge?.copyWith(
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

class _ProjectsGridView extends ConsumerWidget {
  final List projects;
  final bool isLoadingMore;
  final bool hasMore;
  final VoidCallback onLoadMore;

  const _ProjectsGridView({
    required this.projects,
    required this.isLoadingMore,
    required this.hasMore,
    required this.onLoadMore,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification &&
            notification.metrics.extentAfter < 200 &&
            hasMore &&
            !isLoadingMore) {
          onLoadMore();
        }
        return false;
      },
      child: GridView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          childAspectRatio: 0.9,
        ),
        itemCount: projects.length + (isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= projects.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final project = projects[index];
          return ProjectGridCard(
            project: project,
            onTap: () => context.push('/projects/${project.id}'),
            onMoreTap: () => ProjectActionsSheet.show(context, project),
          ).animate().fadeIn(delay: (50 * index).ms).scale(
                begin: const Offset(0.95, 0.95),
                duration: 200.ms,
              );
        },
      ),
    );
  }
}

class _ProjectsListView extends ConsumerWidget {
  final List projects;
  final bool isLoadingMore;
  final bool hasMore;
  final VoidCallback onLoadMore;

  const _ProjectsListView({
    required this.projects,
    required this.isLoadingMore,
    required this.hasMore,
    required this.onLoadMore,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return NotificationListener<ScrollNotification>(
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
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        itemCount: projects.length + (isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= projects.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final project = projects[index];
          return ProjectListTile(
            project: project,
            onTap: () => context.push('/projects/${project.id}'),
            onMoreTap: () => ProjectActionsSheet.show(context, project),
          ).animate().fadeIn(delay: (50 * index).ms).slideX(
                begin: 0.05,
                duration: 200.ms,
              );
        },
      ),
    );
  }
}
