import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/error_utils.dart';
import '../../data/datasources/knowledge_remote_datasource.dart';

// ============================================================
// Data source provider
// ============================================================

final knowledgeDataSourceProvider =
    Provider<KnowledgeRemoteDataSource>((ref) {
  return KnowledgeRemoteDataSource();
});

// ============================================================
// Knowledge Tab State (topics + mastery combined)
// ============================================================

class KnowledgeTabState {
  final bool isLoading;
  final bool isExtracting;
  final List<Map<String, dynamic>> topics;
  final Map<String, dynamic>? knowledgeData;
  final String? error;

  const KnowledgeTabState({
    this.isLoading = false,
    this.isExtracting = false,
    this.topics = const [],
    this.knowledgeData,
    this.error,
  });

  KnowledgeTabState copyWith({
    bool? isLoading,
    bool? isExtracting,
    List<Map<String, dynamic>>? topics,
    Map<String, dynamic>? knowledgeData,
    String? error,
  }) {
    return KnowledgeTabState(
      isLoading: isLoading ?? this.isLoading,
      isExtracting: isExtracting ?? this.isExtracting,
      topics: topics ?? this.topics,
      knowledgeData: knowledgeData ?? this.knowledgeData,
      error: error,
    );
  }

  double get overallMastery =>
      (knowledgeData?['overall_mastery'] as num?)?.toDouble() ?? 0.0;

  int get masteredCount => knowledgeData?['mastered_topics'] as int? ?? 0;
  int get inProgressCount => knowledgeData?['in_progress_topics'] as int? ?? 0;
  int get notStartedCount => knowledgeData?['not_started_topics'] as int? ?? 0;

  List<Map<String, dynamic>> get topicStates =>
      (knowledgeData?['topic_states'] as List?)
          ?.cast<Map<String, dynamic>>() ??
      [];

  /// Find the mastery score for a given topic by matching topic_name.
  double masteryForTopic(String topicName) {
    final match = topicStates.where((s) => s['topic_name'] == topicName);
    if (match.isEmpty) return 0.0;
    return (match.first['mastery_score'] as num?)?.toDouble() ?? 0.0;
  }

  String statusForTopic(String topicName) {
    final match = topicStates.where((s) => s['topic_name'] == topicName);
    if (match.isEmpty) return 'not_started';
    return match.first['status'] as String? ?? 'not_started';
  }
}

// ============================================================
// Knowledge Tab Notifier
// ============================================================

class KnowledgeTabNotifier extends ChangeNotifier {
  final KnowledgeRemoteDataSource _dataSource;
  final String projectId;
  KnowledgeTabState state = const KnowledgeTabState(isLoading: true);

  KnowledgeTabNotifier(this._dataSource, this.projectId) {
    loadAll();
  }

  Future<void> loadAll({bool refresh = false}) async {
    state = state.copyWith(isLoading: true, error: null);
    notifyListeners();

    try {
      final results = await Future.wait([
        _dataSource.listTopics(projectId),
        _dataSource.getProjectKnowledge(projectId),
      ]);

      final topicsData = results[0];
      final knowledgeData = results[1];

      final topics = (topicsData['topics'] as List? ?? [])
          .cast<Map<String, dynamic>>();

      state = KnowledgeTabState(
        topics: topics,
        knowledgeData: knowledgeData,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: friendlyErrorMessage(e));
    }
    notifyListeners();
  }

  Future<void> extractTopics({bool forceRefresh = false}) async {
    state = state.copyWith(isExtracting: true, error: null);
    notifyListeners();

    try {
      final data = await _dataSource.extractTopics(
        projectId,
        forceRefresh: forceRefresh,
      );
      final topics =
          (data['topics'] as List? ?? []).cast<Map<String, dynamic>>();
      state = state.copyWith(isExtracting: false, topics: topics);
    } catch (e) {
      state = state.copyWith(isExtracting: false, error: friendlyErrorMessage(e));
    }
    notifyListeners();
  }
}

final knowledgeTabNotifierProvider =
    Provider.family.autoDispose<KnowledgeTabNotifier, String>(
        (ref, projectId) {
  final notifier = KnowledgeTabNotifier(
    ref.watch(knowledgeDataSourceProvider),
    projectId,
  );
  ref.onDispose(() => notifier.dispose());
  return notifier;
});

// ============================================================
// Progress Stats Notifier (global, for dashboard)
// ============================================================

class ProgressStatsNotifier extends ChangeNotifier {
  final KnowledgeRemoteDataSource _dataSource;
  bool isLoading = true;
  Map<String, dynamic>? stats;
  String? error;

  ProgressStatsNotifier(this._dataSource) {
    load();
  }

  Future<void> load() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      stats = await _dataSource.getProgressStats();
      isLoading = false;
    } catch (e) {
      error = friendlyErrorMessage(e);
      isLoading = false;
    }
    notifyListeners();
  }
}

final progressStatsNotifierProvider =
    Provider.autoDispose<ProgressStatsNotifier>((ref) {
  final notifier =
      ProgressStatsNotifier(ref.watch(knowledgeDataSourceProvider));
  ref.onDispose(() => notifier.dispose());
  return notifier;
});
