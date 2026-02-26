import '../../../../core/network/network.dart';
import '../../../../core/constants/constants.dart';

class SmartTutorRemoteDataSource {
  final ApiClient _apiClient;

  SmartTutorRemoteDataSource({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<Map<String, dynamic>> getAdaptiveDifficulty(String projectId) async {
    final response =
        await _apiClient.get(ApiConstants.adaptiveDifficulty(projectId));
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getSmartSuggestions({int limit = 5}) async {
    final response = await _apiClient.get(
      ApiConstants.smartSuggestions,
      queryParameters: {'limit': limit},
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getStudyPlan(
    String projectId, {
    String? examDate,
    double dailyHours = 2.0,
  }) async {
    final params = <String, dynamic>{'daily_hours': dailyHours};
    if (examDate != null) params['exam_date'] = examDate;

    final response = await _apiClient.get(
      ApiConstants.studyPlan(projectId),
      queryParameters: params,
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getExamReadiness(String projectId) async {
    final response =
        await _apiClient.get(ApiConstants.examReadiness(projectId));
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getCrossConnections(String projectId) async {
    final response =
        await _apiClient.get(ApiConstants.crossConnections(projectId));
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getLearningStyle() async {
    final response = await _apiClient.get(ApiConstants.learningStyle);
    return response.data as Map<String, dynamic>;
  }
}
