import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../conversations/presentation/providers/providers.dart';
import '../../../projects/presentation/providers/providers.dart';

/// Dashboard statistics.
class DashboardStats {
  final int totalProjects;
  final int totalConversations;
  final int totalDocuments;
  final int dayStreak; // Placeholder - would need backend support

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

/// Provider that aggregates dashboard statistics from various sources.
final dashboardStatsProvider = Provider.autoDispose<DashboardStats>((ref) {
  // Watch projects state
  final projectsState = ref.watch(projectsNotifierProvider);
  
  // Watch conversations notifier
  final conversationsNotifier = ref.watch(conversationsNotifierProvider);
  final conversationsState = conversationsNotifier.state;

  // Calculate totals
  int totalProjects = 0;
  int totalConversations = 0;
  int totalDocuments = 0;

  // Get projects count
  projectsState.whenOrNull(
    loaded: (projects, isLoadingMore, hasMore) {
      totalProjects = projects.length;
      // TODO: Sum document counts from all projects
      // For now, we'll need to fetch document stats per project
      // This is a limitation - ideally backend would provide aggregated stats
    },
  );

  // Get conversations count
  conversationsState.whenOrNull(
    loaded: (conversations, total, isLoadingMore, hasMore) {
      totalConversations = total;
    },
  );

  return DashboardStats(
    totalProjects: totalProjects,
    totalConversations: totalConversations,
    totalDocuments: totalDocuments, // Will be 0 until we aggregate
    dayStreak: 0, // Placeholder
  );
});
