import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/widgets.dart';
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
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 72),
        child: FloatingActionButton.extended(
          onPressed: () => CreateProjectSheet.show(context),
          icon: const Icon(LucideIcons.plus),
          label: const Text('New Project'),
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const ShimmerProjectGrid(itemCount: 6);
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onCreateProject;

  const _EmptyState({required this.onCreateProject});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: LucideIcons.folderOpen,
      title: 'No projects yet',
      subtitle: 'Create your first project to organize\nyour study materials and conversations.',
      actionLabel: 'Create Project',
      onAction: onCreateProject,
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ErrorState(message: message, onRetry: onRetry);
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
            onTap: () {
              context.push('/projects/${project.id}');
            },
            onMoreTap: () => ProjectActionsSheet.show(context, project),
          )
              .animate()
              .fadeIn(delay: (50 * index).ms, duration: 300.ms)
              .scale(
                begin: const Offset(0.95, 0.95),
                end: const Offset(1, 1),
                delay: (50 * index).ms,
                duration: 300.ms,
                curve: Curves.easeOutCubic,
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
            onTap: () {
              context.push('/projects/${project.id}');
            },
            onMoreTap: () => ProjectActionsSheet.show(context, project),
          )
              .animate()
              .fadeIn(delay: (50 * index).ms, duration: 300.ms)
              .slideX(
                begin: 0.05,
                end: 0,
                delay: (50 * index).ms,
                duration: 300.ms,
                curve: Curves.easeOutCubic,
              );
        },
      ),
    );
  }
}
