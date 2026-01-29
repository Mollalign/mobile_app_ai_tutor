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
  ProjectDetailChangeNotifier? _notifier;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _notifier?.removeListener(_onNotifierChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onNotifierChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final projectNotifier = ref.watch(projectDetailNotifierProvider(widget.projectId));
    
    // Set up listener for ChangeNotifier updates
    if (_notifier != projectNotifier) {
      _notifier?.removeListener(_onNotifierChanged);
      _notifier = projectNotifier;
      _notifier?.addListener(_onNotifierChanged);
    }
    
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
              expandedHeight: 140,
              floating: false,
              pinned: true,
              forceElevated: innerBoxIsScrolled,
              title: innerBoxIsScrolled ? Text(project.name) : null,
              actions: [
                IconButton(
                  onPressed: () => ProjectActionsSheet.show(context, project),
                  icon: const Icon(LucideIcons.moreVertical),
                ),
              ],
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
                  child: SafeArea(
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
                              const SizedBox(width: AppSpacing.sm),
                              if (project.isArchived)
                                Container(
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
                                    style: textTheme.bodySmall?.copyWith(
                                      color: Colors.white.withAlpha(200),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            project.name,
                            style: textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (project.hasDescription) ...[
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              project.shortDescription ?? '',
                              style: textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withAlpha(180),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
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
