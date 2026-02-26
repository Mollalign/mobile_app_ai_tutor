import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/smart_tutor_remote_datasource.dart';

final smartTutorDataSourceProvider = Provider<SmartTutorRemoteDataSource>(
  (ref) => SmartTutorRemoteDataSource(),
);

final smartSuggestionsProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final ds = ref.watch(smartTutorDataSourceProvider);
  return ds.getSmartSuggestions();
});

final learningStyleProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final ds = ref.watch(smartTutorDataSourceProvider);
  return ds.getLearningStyle();
});

final adaptiveDifficultyProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, String>((ref, projectId) async {
  final ds = ref.watch(smartTutorDataSourceProvider);
  return ds.getAdaptiveDifficulty(projectId);
});

final examReadinessProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, String>((ref, projectId) async {
  final ds = ref.watch(smartTutorDataSourceProvider);
  return ds.getExamReadiness(projectId);
});

final studyPlanProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, ({String projectId, String? examDate, double dailyHours})>(
  (ref, args) async {
    final ds = ref.watch(smartTutorDataSourceProvider);
    return ds.getStudyPlan(
      args.projectId,
      examDate: args.examDate,
      dailyHours: args.dailyHours,
    );
  },
);

final crossConnectionsProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, String>((ref, projectId) async {
  final ds = ref.watch(smartTutorDataSourceProvider);
  return ds.getCrossConnections(projectId);
});
