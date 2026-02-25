import '../../../../core/network/network.dart';
import '../../../../core/constants/constants.dart';

/// Remote data source for topic extraction and knowledge tracking APIs.
class KnowledgeRemoteDataSource {
  final ApiClient _apiClient;

  KnowledgeRemoteDataSource({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// GET /projects/{projectId}/topics
  Future<Map<String, dynamic>> listTopics(String projectId) async {
    final response = await _apiClient.get(ApiConstants.topics(projectId));
    return response.data as Map<String, dynamic>;
  }

  /// POST /projects/{projectId}/topics/extract
  Future<Map<String, dynamic>> extractTopics(
    String projectId, {
    bool forceRefresh = false,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.extractTopics(projectId),
      data: {'force_refresh': forceRefresh},
    );
    return response.data as Map<String, dynamic>;
  }

  /// GET /projects/{projectId}/knowledge
  Future<Map<String, dynamic>> getProjectKnowledge(String projectId) async {
    final response =
        await _apiClient.get(ApiConstants.projectKnowledge(projectId));
    return response.data as Map<String, dynamic>;
  }

  /// GET /progress/stats
  Future<Map<String, dynamic>> getProgressStats() async {
    final response = await _apiClient.get(ApiConstants.progressStats);
    return response.data as Map<String, dynamic>;
  }
}
