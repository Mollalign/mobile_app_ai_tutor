import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../shared/widgets/widgets.dart';
import '../../../projects/domain/entities/entities.dart';
import '../../../projects/presentation/providers/providers.dart';
import '../../../projects/presentation/widgets/create_project_sheet.dart';
import '../../../projects/presentation/widgets/project_actions_sheet.dart';

class ProjectsTab extends ConsumerStatefulWidget {
  const ProjectsTab({super.key});

  @override
  ConsumerState<ProjectsTab> createState() => _ProjectsTabState();
}

class _ProjectsTabState extends ConsumerState<ProjectsTab> {
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projectsState = ref.watch(projectsNotifierProvider);
    final isGridView = ref.watch(projectsViewModeProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                'Projects',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
            ),
        actions: [
          IconButton(
            onPressed: () {
              ref.read(projectsViewModeProvider.notifier).toggle();
            },
            icon: Icon(
                  isGridView
                      ? LucideIcons.list
                      : LucideIcons.layoutGrid,
                  size: 20,
                  color: colorScheme.onSurfaceVariant,
            ),
            tooltip: isGridView ? 'List view' : 'Grid view',
                style: IconButton.styleFrom(
                  backgroundColor:
                      colorScheme.surfaceContainerHighest.withAlpha(180),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
          ),

          // Search bar + stats
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: Column(
                children: [
                  // Search bar
                  Container(
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
                      onChanged: (v) => setState(() => _searchQuery = v),
                      decoration: InputDecoration(
                        hintText: 'Search projects...',
                        prefixIcon: Icon(LucideIcons.search,
                            size: 18,
                            color: colorScheme.onSurfaceVariant),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(LucideIcons.x,
                                    size: 16,
                                    color:
                                        colorScheme.onSurfaceVariant),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ).animate().fadeIn(duration: 300.ms),
                  const SizedBox(height: 16),
                  // Stats summary
                  projectsState.whenOrNull(
                        loaded: (projects, isLoadingMore, hasMore) {
                          final active = projects
                              .where((p) => !p.isArchived)
                              .length;
                          final archived = projects
                              .where((p) => p.isArchived)
                              .length;
                          return _ProjectStatsBar(
                            total: projects.length,
                            active: active,
                            archived: archived,
                            colorScheme: colorScheme,
                            textTheme: textTheme,
                            isDark: isDark,
                          );
                        },
                      ) ??
                      const SizedBox.shrink(),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          // Content
          projectsState.when(
            initial: () => const SliverFillRemaining(
              child: _LoadingState(),
            ),
            loading: () => const SliverFillRemaining(
              child: _LoadingState(),
            ),
        loaded: (projects, isLoadingMore, hasMore) {
              final filtered = _searchQuery.isEmpty
                  ? projects
                  : projects
                      .where((p) => p.name
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase()))
                      .toList();

          if (projects.isEmpty) {
                return SliverFillRemaining(
                  child: _EmptyState(
                    onCreateProject: () =>
                        CreateProjectSheet.show(context),
                  ),
                );
              }

              if (filtered.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.searchX,
                            size: 48,
                            color: colorScheme.onSurfaceVariant
                                .withAlpha(120)),
                        const SizedBox(height: 12),
                        Text(
                          'No projects match "$_searchQuery"',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (isGridView) {
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.82,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index >= filtered.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        final project = filtered[index];
                        return _ModernGridCard(
                          project: project,
                          onTap: () =>
                              context.push('/projects/${project.id}'),
                          onMoreTap: () => ProjectActionsSheet.show(
                              context, project),
                        )
                            .animate()
                            .fadeIn(
                              delay: Duration(
                                  milliseconds:
                                      index < 10 ? 40 * index : 0),
                              duration: 300.ms,
                            )
                            .scale(
                              begin: const Offset(0.95, 0.95),
                              end: const Offset(1, 1),
                              delay: Duration(
                                  milliseconds:
                                      index < 10 ? 40 * index : 0),
                              duration: 300.ms,
                              curve: Curves.easeOutCubic,
                            );
                      },
                      childCount: filtered.length +
                          (isLoadingMore ? 1 : 0),
                    ),
                  ),
                );
              } else {
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index >= filtered.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        final project = filtered[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _ModernListCard(
                            project: project,
                            onTap: () => context
                                .push('/projects/${project.id}'),
                            onMoreTap: () =>
                                ProjectActionsSheet.show(
                                    context, project),
                          )
                              .animate()
                              .fadeIn(
                                delay: Duration(
                                    milliseconds:
                                        index < 10 ? 50 * index : 0),
                                duration: 350.ms,
                              )
                              .slideX(
                                begin: 0.04,
                                end: 0,
                                delay: Duration(
                                    milliseconds:
                                        index < 10 ? 50 * index : 0),
                                duration: 350.ms,
                              ),
                        );
                      },
                      childCount: filtered.length +
                          (isLoadingMore ? 1 : 0),
                    ),
                  ),
                );
              }
            },
            error: (message) => SliverFillRemaining(
              child: _ErrorState(
          message: message,
          onRetry: () => ref
              .read(projectsNotifierProvider.notifier)
              .loadProjects(refresh: true),
        ),
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 72),
        child: FloatingActionButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            CreateProjectSheet.show(context);
          },
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 4,
          child: const Icon(LucideIcons.plus, size: 24),
        ),
      ),
    );
  }
}

// ============================================================
// Project Stats Bar
// ============================================================

class _ProjectStatsBar extends StatelessWidget {
  final int total;
  final int active;
  final int archived;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final bool isDark;

  const _ProjectStatsBar({
    required this.total,
    required this.active,
    required this.archived,
    required this.colorScheme,
    required this.textTheme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatChip(
          label: '$total Total',
          color: colorScheme.primary,
          isDark: isDark,
        ),
        const SizedBox(width: 8),
        _StatChip(
          label: '$active Active',
          color: Colors.green,
          isDark: isDark,
        ),
        if (archived > 0) ...[
          const SizedBox(width: 8),
          _StatChip(
            label: '$archived Archived',
            color: colorScheme.onSurfaceVariant,
            isDark: isDark,
          ),
        ],
      ],
    ).animate().fadeIn(delay: 150.ms, duration: 300.ms);
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool isDark;

  const _StatChip({
    required this.label,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withAlpha(isDark ? 25 : 15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withAlpha(isDark ? 50 : 30),
        ),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

// ============================================================
// Helpers
// ============================================================

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

String _projectInitials(String name) {
  final words = name.trim().split(RegExp(r'\s+'));
  if (words.length >= 2) {
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }
  return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
}

// ============================================================
// Modern Grid Card
// ============================================================

class _ModernGridCard extends StatelessWidget {
  final Project project;
  final VoidCallback onTap;
  final VoidCallback? onMoreTap;

  const _ModernGridCard({
    required this.project,
    required this.onTap,
    this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = _projectAccent(project.name, colorScheme);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        onLongPress: onMoreTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? colorScheme.surfaceContainerHighest
                : colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? colorScheme.outlineVariant.withAlpha(35)
                  : colorScheme.outlineVariant.withAlpha(80),
            ),
            boxShadow: [
              BoxShadow(
                color: accent.withAlpha(isDark ? 15 : 12),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Accent header strip
              Container(
                height: 6,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      accent,
                      accent.withAlpha(150),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header row
                      Row(
                        children: [
                          // Initials avatar
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  accent,
                                  accent.withAlpha(180),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: accent.withAlpha(isDark ? 40 : 50),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                _projectInitials(project.name),
                                style: textTheme.labelMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                          const Spacer(),
                          if (onMoreTap != null)
                            GestureDetector(
                              onTap: onMoreTap,
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: colorScheme.onSurfaceVariant
                                      .withAlpha(isDark ? 20 : 12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  LucideIcons.moreHorizontal,
                                  size: 14,
                                  color: colorScheme.onSurfaceVariant
                                      .withAlpha(160),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Name
                      Text(
                        project.name,
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: project.isArchived
                              ? colorScheme.onSurfaceVariant
                              : colorScheme.onSurface,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      if (project.hasDescription) ...[
                        const SizedBox(height: 4),
                        Text(
                          project.shortDescription ?? '',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 11,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],

                      const Spacer(),

                      // Footer
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: (project.isArchived
                                      ? colorScheme.onSurfaceVariant
                                      : Colors.green)
                                  .withAlpha(isDark ? 25 : 15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 5,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: project.isArchived
                                        ? colorScheme.onSurfaceVariant
                                        : Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  project.isArchived
                                      ? 'Archived'
                                      : 'Active',
                                  style: textTheme.labelSmall?.copyWith(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    color: project.isArchived
                                        ? colorScheme.onSurfaceVariant
                                        : Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Icon(LucideIcons.clock,
                              size: 10,
                              color: colorScheme.onSurfaceVariant
                                  .withAlpha(130)),
                          const SizedBox(width: 3),
                          Text(
                            project.lastUpdatedRelative,
                            style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant
                                  .withAlpha(160),
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
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
// Modern List Card
// ============================================================

class _ModernListCard extends StatelessWidget {
  final Project project;
  final VoidCallback onTap;
  final VoidCallback? onMoreTap;

  const _ModernListCard({
    required this.project,
    required this.onTap,
    this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = _projectAccent(project.name, colorScheme);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        onLongPress: onMoreTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? colorScheme.surfaceContainerHighest
                : colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark
                  ? colorScheme.outlineVariant.withAlpha(35)
                  : colorScheme.outlineVariant.withAlpha(80),
            ),
            boxShadow: [
              BoxShadow(
                color: accent.withAlpha(isDark ? 12 : 10),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Left accent bar
              Container(
                width: 5,
                height: 72,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [accent, accent.withAlpha(120)],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    bottomLeft: Radius.circular(18),
                  ),
                ),
              ),

              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 14, 14, 14),
                  child: Row(
                    children: [
                      // Initials avatar
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              accent,
                              accent.withAlpha(180),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(13),
                          boxShadow: [
                            BoxShadow(
                              color: accent.withAlpha(isDark ? 35 : 45),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            _projectInitials(project.name),
                            style: textTheme.labelMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Text content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              project.name,
                              style: textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: project.isArchived
                                    ? colorScheme.onSurfaceVariant
                                    : colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (project.hasDescription) ...[
                              const SizedBox(height: 2),
                              Text(
                                project.shortDescription ?? '',
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                // Status pill
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: (project.isArchived
                                            ? colorScheme.onSurfaceVariant
                                            : Colors.green)
                                        .withAlpha(isDark ? 25 : 15),
                                    borderRadius:
                                        BorderRadius.circular(5),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 5,
                                        height: 5,
                                        decoration: BoxDecoration(
                                          color: project.isArchived
                                              ? colorScheme
                                                  .onSurfaceVariant
                                              : Colors.green,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        project.isArchived
                                            ? 'Archived'
                                            : 'Active',
                                        style: textTheme.labelSmall
                                            ?.copyWith(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w600,
                                          color: project.isArchived
                                              ? colorScheme
                                                  .onSurfaceVariant
                                              : Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(LucideIcons.clock,
                                    size: 10,
                                    color: colorScheme
                                        .onSurfaceVariant
                                        .withAlpha(130)),
                                const SizedBox(width: 3),
                                Expanded(
                                  child: Text(
                                    project.lastUpdatedRelative,
                                    style:
                                        textTheme.labelSmall?.copyWith(
                                      color: colorScheme
                                          .onSurfaceVariant
                                          .withAlpha(160),
                                      fontSize: 9,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 6),
                      // Actions
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (onMoreTap != null)
                            GestureDetector(
                              onTap: onMoreTap,
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: colorScheme.onSurfaceVariant
                                      .withAlpha(isDark ? 20 : 12),
                                  borderRadius:
                                      BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  LucideIcons.moreHorizontal,
                                  size: 14,
                                  color: colorScheme.onSurfaceVariant
                                      .withAlpha(160),
                                ),
                              ),
                            ),
                          const SizedBox(height: 6),
                          Icon(
                            LucideIcons.chevronRight,
                            size: 14,
                            color: colorScheme.onSurfaceVariant
                                .withAlpha(100),
                          ),
                        ],
                      ),
                    ],
                  ),
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
// Loading / Empty / Error States
// ============================================================

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
      subtitle:
          'Create your first project to organize\nyour study materials and conversations.',
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
