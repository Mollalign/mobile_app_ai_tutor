import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../shared/widgets/shimmer_loading.dart';
import '../../domain/entities/entities.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';
import 'tabs/overview_tab.dart';
import 'tabs/documents_tab.dart';
import 'tabs/conversations_tab.dart';
import '../../../quizzes/presentation/screens/quizzes_tab.dart';
import '../../../knowledge/presentation/screens/knowledge_tab.dart';

class ProjectDetailScreen extends ConsumerStatefulWidget {
  final String projectId;

  const ProjectDetailScreen({
    super.key,
    required this.projectId,
  });

  @override
  ConsumerState<ProjectDetailScreen> createState() =>
      _ProjectDetailScreenState();
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

  Color _projectAccent(ColorScheme cs, String name) {
    final hash = name.hashCode;
    final colors = [
      cs.primary,
      cs.secondary,
      cs.tertiary,
      Colors.orange,
      Colors.teal,
      Colors.indigo,
    ];
    return colors[hash.abs() % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final projectNotifier =
        ref.watch(projectDetailNotifierProvider(widget.projectId));

    return AnimatedBuilder(
      animation: projectNotifier,
      builder: (context, _) {
        final state = projectNotifier.state;

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
        title: AppShimmer(
          child: ShimmerBox(
            width: MediaQuery.of(context).size.width * 0.35,
            height: 20,
          ),
        ),
      ),
      body: const ShimmerConversationList(itemCount: 5),
    );
  }

  Widget _buildErrorScaffold(BuildContext context, String message) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(LucideIcons.alertCircle,
                    size: 36, color: colorScheme.error),
              ),
              const SizedBox(height: 20),
              Text('Failed to load project',
                  style: textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(message,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium
                      ?.copyWith(color: colorScheme.onSurfaceVariant)),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => ref
                    .read(
                        projectDetailNotifierProvider(widget.projectId))
                    .loadProject(),
                icon: const Icon(LucideIcons.refreshCw, size: 18),
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
    final accent = _projectAccent(colorScheme, project.name);

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 180,
              floating: false,
              pinned: true,
              backgroundColor: colorScheme.surface,
              surfaceTintColor: Colors.transparent,
              title: innerBoxIsScrolled ? Text(project.name) : null,
              actions: [
                IconButton(
                  onPressed: () =>
                      ProjectActionsSheet.show(context, project),
                  icon: Icon(
                    LucideIcons.moreVertical,
                    color:
                        innerBoxIsScrolled ? null : Colors.white,
                  ),
                ),
              ],
              leading: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(
                  LucideIcons.arrowLeft,
                  color:
                      innerBoxIsScrolled ? null : Colors.white,
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        accent,
                        Color.lerp(accent, colorScheme.tertiary, 0.5)!,
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Decorative circles
                      Positioned(
                        right: -30,
                        top: -10,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withAlpha(12),
                          ),
                        ),
                      ),
                      Positioned(
                        left: -20,
                        bottom: 40,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withAlpha(8),
                          ),
                        ),
                      ),
                      SafeArea(
                        bottom: false,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                              24, 56, 24, 24),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.white.withAlpha(25),
                                      borderRadius:
                                          BorderRadius.circular(14),
                                    ),
                                    child: Icon(
                                      project.isArchived
                                          ? LucideIcons.archive
                                          : LucideIcons.folder,
                                      size: 22,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (project.isArchived)
                                          Container(
                                            margin:
                                                const EdgeInsets.only(
                                                    bottom: 4),
                                            padding: const EdgeInsets
                                                .symmetric(
                                                horizontal: 8,
                                                vertical: 3),
                                            decoration: BoxDecoration(
                                              color: Colors.white
                                                  .withAlpha(20),
                                              borderRadius:
                                                  BorderRadius
                                                      .circular(8),
                                            ),
                                            child: Text(
                                              'Archived',
                                              style: textTheme
                                                  .labelSmall
                                                  ?.copyWith(
                                                color: Colors.white
                                                    .withAlpha(200),
                                              ),
                                            ),
                                          ),
                                        Text(
                                          project.name,
                                          style: textTheme
                                              .headlineSmall
                                              ?.copyWith(
                                            color: Colors.white,
                                            fontWeight:
                                                FontWeight.w800,
                                            letterSpacing: -0.3,
                                          ),
                                          maxLines: 1,
                                          overflow:
                                              TextOverflow.ellipsis,
                                        ),
                                        if (project.hasDescription)
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(
                                                    top: 4),
                                            child: Text(
                                              project.description!,
                                              style: textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                color: Colors.white
                                                    .withAlpha(170),
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow
                                                  .ellipsis,
                                            ),
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
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    border: Border(
                      bottom: BorderSide(
                        color: colorScheme.outlineVariant
                            .withAlpha(isDark ? 30 : 60),
                      ),
                    ),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    labelColor: accent,
                    unselectedLabelColor:
                        colorScheme.onSurfaceVariant,
                    indicatorColor: accent,
                    indicatorWeight: 3,
                    dividerHeight: 0,
                    labelStyle: textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    tabs: const [
                      Tab(
                        icon: Icon(LucideIcons.layoutDashboard,
                            size: 16),
                        text: 'Overview',
                      ),
                      Tab(
                        icon:
                            Icon(LucideIcons.fileText, size: 16),
                        text: 'Docs',
                      ),
                      Tab(
                        icon: Icon(LucideIcons.messageSquare,
                            size: 16),
                        text: 'Chats',
                      ),
                      Tab(
                        icon: Icon(LucideIcons.brainCircuit,
                            size: 16),
                        text: 'Quizzes',
                      ),
                      Tab(
                        icon:
                            Icon(LucideIcons.bookOpen, size: 16),
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
