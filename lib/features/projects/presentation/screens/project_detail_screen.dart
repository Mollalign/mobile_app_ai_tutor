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
import '../../../quizzes/presentation/screens/quizzes_tab.dart';
import '../../../knowledge/presentation/screens/knowledge_tab.dart';

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
    _tabController = TabController(length: 5, vsync: this);
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 160,
              floating: false,
              pinned: true,
              backgroundColor: colorScheme.surface,
              surfaceTintColor: Colors.transparent,
              title: innerBoxIsScrolled ? Text(project.name) : null,
              actions: [
                IconButton(
                  onPressed: () => ProjectActionsSheet.show(context, project),
                  icon: Icon(
                    LucideIcons.moreVertical,
                    color: innerBoxIsScrolled ? null : Colors.white,
                  ),
                ),
              ],
              leading: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(
                  LucideIcons.arrowLeft,
                  color: innerBoxIsScrolled ? null : Colors.white,
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colorScheme.primary,
                        Color.lerp(colorScheme.primary, colorScheme.secondary, 0.5)!,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.xxl,
                        AppSpacing.lg,
                        AppSpacing.lg,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(38),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(
                                  project.isArchived
                                      ? LucideIcons.archive
                                      : LucideIcons.folder,
                                  size: 22,
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
                                          horizontal: 6,
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
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    border: Border(
                      bottom: BorderSide(
                        color: colorScheme.outlineVariant.withAlpha(isDark ? 38 : 77),
                      ),
                    ),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    labelColor: colorScheme.primary,
                    unselectedLabelColor: colorScheme.onSurfaceVariant,
                    indicatorColor: colorScheme.primary,
                    indicatorWeight: 3,
                    labelStyle: textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    tabs: const [
                      Tab(
                        icon: Icon(LucideIcons.layoutDashboard, size: 18),
                        text: 'Overview',
                      ),
                      Tab(
                        icon: Icon(LucideIcons.fileText, size: 18),
                        text: 'Docs',
                      ),
                      Tab(
                        icon: Icon(LucideIcons.messageSquare, size: 18),
                        text: 'Chats',
                      ),
                      Tab(
                        icon: Icon(LucideIcons.brainCircuit, size: 18),
                        text: 'Quizzes',
                      ),
                      Tab(
                        icon: Icon(LucideIcons.bookOpen, size: 18),
                        text: 'Knowledge',
                      ),
                    ],
                  ),
                ),
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
            QuizzesTab(projectId: widget.projectId),
            KnowledgeTab(projectId: widget.projectId),
          ],
        ),
      ),
    );
  }
}
