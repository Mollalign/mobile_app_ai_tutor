import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../conversations/presentation/providers/providers.dart';
import '../../../knowledge/presentation/providers/knowledge_provider.dart';
import '../../../projects/presentation/providers/providers.dart';

/// Dashboard statistics.
class DashboardStats {
  final int totalProjects;
  final int totalConversations;
  final int totalDocuments;
  final int dayStreak;

  const DashboardStats({
    required this.totalProjects,
    required this.totalConversations,
    required this.totalDocuments,
    this.dayStreak = 0,
  });

  static const empty = DashboardStats(
    totalProjects: 0,
    totalConversations: 0,
    totalDocuments: 0,
    dayStreak: 0,
  );
}

final dashboardStatsProvider = Provider.autoDispose<DashboardStats>((ref) {
  final projectsState = ref.watch(projectsNotifierProvider);
  final conversationsNotifier = ref.watch(conversationsNotifierProvider);
  final conversationsState = conversationsNotifier.state;
  final progressNotifier = ref.watch(progressStatsNotifierProvider);

  int totalProjects = 0;
  int totalConversations = 0;

  projectsState.whenOrNull(
    loaded: (projects, isLoadingMore, hasMore) {
      totalProjects = projects.where((p) => !p.isArchived).length;
    },
  );

  conversationsState.whenOrNull(
    loaded: (conversations, total, isLoadingMore, hasMore) {
      totalConversations = total;
    },
  );

  int dayStreak = 0;
  if (progressNotifier.stats != null) {
    dayStreak = progressNotifier.stats!['study_streak'] as int? ?? 0;
  }

  return DashboardStats(
    totalProjects: totalProjects,
    totalConversations: totalConversations,
    totalDocuments: 0,
    dayStreak: dayStreak,
  );
});
