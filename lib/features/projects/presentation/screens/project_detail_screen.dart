import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../domain/entities/entities.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';
import 'tabs/overview_tab.dart';
import 'tabs/documents_tab.dart';
import 'tabs/conversations_tab.dart';

/// Project detail screen with tabs.
/// 
/// Shows:
/// - Overview: Project info and stats
/// - Documents: List of uploaded documents
/// - Conversations: Chats related to this project
class ProjectDetailScreen extends ConsumerStatefulWidget {
  final String projectId;

  const ProjectDetailScreen({
    super.key,
    required this.projectId,
  });

  @override
  ConsumerState<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends ConsumerState<ProjectDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projectNotifier = ref.watch(projectDetailNotifierProvider(widget.projectId));
    
    return AnimatedBuilder(
      animation: projectNotifier,
      builder: (context, _) {
        final state = projectNotifier.state;

        // Load project if in initial state
        state.whenOrNull(
          initial: () {
            SchedulerBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                projectNotifier.loadProject();
              }
            });
          },
        );

        return state.when(
          initial: () => _buildLoadingScaffold(context),
          loading: () => _buildLoadingScaffold(context),
          loaded: (project) => _buildLoadedScaffold(context, project),
          error: (message) => _buildErrorScaffold(context, message),
        );
      },
    );
  }

  Widget _buildLoadingScaffold(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loading...'),
      ),
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorScaffold(BuildContext context, String message) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
      ),
      body: Center(
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
                'Failed to load project',
                style: textTheme.titleLarge,
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
                onPressed: () {
                  ref.read(projectDetailNotifierProvider(widget.projectId)).loadProject();
                },
                icon: const Icon(LucideIcons.refreshCw),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadedScaffold(BuildContext context, Project project) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 180,
              floating: false,
              pinned: true,
              forceElevated: innerBoxIsScrolled,
              backgroundColor: innerBoxIsScrolled ? colorScheme.surface : Colors.transparent,
              foregroundColor: innerBoxIsScrolled ? colorScheme.onSurface : Colors.white,
              title: innerBoxIsScrolled ? Text(project.name) : null,
              actions: [
                IconButton(
                  onPressed: () => ProjectActionsSheet.show(context, project),
                  icon: const Icon(LucideIcons.moreVertical),
                ),
              ],
              iconTheme: IconThemeData(
                color: innerBoxIsScrolled ? colorScheme.onSurface : Colors.white,
              ),
              actionsIconTheme: IconThemeData(
                color: innerBoxIsScrolled ? colorScheme.onSurface : Colors.white,
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colorScheme.primary,
                        colorScheme.primary.withAlpha(200),
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Scrim gradient at the top for better icon visibility
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: 120,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withAlpha(77),  // ~30% opacity
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Content
                      SafeArea(
                        bottom: false,
                        child: Padding(
                          // Add bottom padding to account for TabBar height (~72px with icon+text)
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.lg,
                            AppSpacing.lg,
                            AppSpacing.lg,
                            80, // Space for TabBar
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(AppSpacing.sm),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withAlpha(50),
                                      borderRadius: AppRadius.borderRadiusSm,
                                    ),
                                    child: Icon(
                                      project.isArchived
                                          ? LucideIcons.archive
                                          : LucideIcons.folder,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (project.isArchived)
                                          Container(
                                            margin: const EdgeInsets.only(bottom: 4),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: AppSpacing.sm,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withAlpha(30),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              'Archived',
                                              style: textTheme.labelSmall?.copyWith(
                                                color: Colors.white.withAlpha(200),
                                              ),
                                            ),
                                          ),
                                        Text(
                                          project.name,
                                          style: textTheme.headlineSmall?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
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
              bottom: TabBar(
                controller: _tabController,
                labelColor: colorScheme.primary,
                unselectedLabelColor: colorScheme.onSurfaceVariant,
                indicatorColor: colorScheme.primary,
                tabs: const [
                  Tab(
                    icon: Icon(LucideIcons.layoutDashboard, size: 18),
                    text: 'Overview',
                  ),
                  Tab(
                    icon: Icon(LucideIcons.fileText, size: 18),
                    text: 'Documents',
                  ),
                  Tab(
                    icon: Icon(LucideIcons.messageSquare, size: 18),
                    text: 'Chats',
                  ),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            OverviewTab(project: project),
            DocumentsTab(projectId: widget.projectId),
            ConversationsTab(projectId: widget.projectId),
          ],
        ),
      ),
    );
  }
}
