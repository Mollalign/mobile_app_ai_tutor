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
/// 
/// LIMITATION: Documents count requires either:
/// 1. A backend endpoint that returns aggregated user stats (recommended)
/// 2. Adding a `documentCount` field to the Project entity
/// 
/// For now, totalDocuments will show 0 until one of these solutions is implemented.
/// Backend endpoint suggestion: GET /api/users/me/stats
/// Response: { total_projects, total_conversations, total_documents, day_streak }
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

  // Get projects count (excludes loading state)
  projectsState.whenOrNull(
    loaded: (projects, isLoadingMore, hasMore) {
      totalProjects = projects.where((p) => !p.isArchived).length;
    },
  );

  // Get conversations count from the total field
  conversationsState.whenOrNull(
    loaded: (conversations, total, isLoadingMore, hasMore) {
      totalConversations = total;
    },
  );

  // TODO: Implement one of these solutions for documents count:
  // Option 1: Create GET /api/users/me/stats endpoint (recommended)
  // Option 2: Add documentCount field to Project model and API
  // Option 3: Sum documents by iterating project document providers (expensive)

  return DashboardStats(
    totalProjects: totalProjects,
    totalConversations: totalConversations,
    totalDocuments: totalDocuments,
    dayStreak: 0, // Requires backend tracking of daily activity
  );
});
