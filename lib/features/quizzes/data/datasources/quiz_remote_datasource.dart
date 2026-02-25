import '../../../../core/network/network.dart';
import '../../../../core/constants/constants.dart';

/// Remote data source for quiz API calls.
class QuizRemoteDataSource {
  final ApiClient _apiClient;

  QuizRemoteDataSource({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// POST /projects/{projectId}/quizzes/generate
  Future<Map<String, dynamic>> generateQuiz(
    String projectId, {
    int numQuestions = 5,
    String difficulty = 'medium',
    List<String> questionTypes = const ['multiple_choice', 'true_false'],
    String? topicFocus,
    String? title,
  }) async {
    final body = <String, dynamic>{
      'num_questions': numQuestions,
      'difficulty': difficulty,
      'question_types': questionTypes,
    };
    if (topicFocus != null) body['topic_focus'] = topicFocus;
    if (title != null) body['title'] = title;

    final response = await _apiClient.post(
      ApiConstants.generateQuiz(projectId),
      data: body,
    );
    return response.data as Map<String, dynamic>;
  }

  /// GET /projects/{projectId}/quizzes
  Future<Map<String, dynamic>> listQuizzes(
    String projectId, {
    int skip = 0,
    int limit = 20,
  }) async {
    final response = await _apiClient.get(
      ApiConstants.quizzes(projectId),
      queryParameters: {'skip': skip, 'limit': limit},
    );
    return response.data as Map<String, dynamic>;
  }

  /// GET /quizzes/{quizId}
  Future<Map<String, dynamic>> getQuiz(String quizId) async {
    final response = await _apiClient.get(ApiConstants.quiz(quizId));
    return response.data as Map<String, dynamic>;
  }

  /// POST /quizzes/{quizId}/submit
  Future<Map<String, dynamic>> submitQuiz(
    String quizId, {
    required List<Map<String, dynamic>> answers,
    int? timeTakenSeconds,
  }) async {
    final body = <String, dynamic>{
      'answers': answers,
    };
    if (timeTakenSeconds != null) body['time_taken_seconds'] = timeTakenSeconds;

    final response = await _apiClient.post(
      ApiConstants.submitQuiz(quizId),
      data: body,
    );
    return response.data as Map<String, dynamic>;
  }

  /// GET /quizzes/{quizId}/attempts
  Future<Map<String, dynamic>> listAttempts(
    String quizId, {
    int skip = 0,
    int limit = 20,
  }) async {
    final response = await _apiClient.get(
      ApiConstants.quizAttempts(quizId),
      queryParameters: {'skip': skip, 'limit': limit},
    );
    return response.data as Map<String, dynamic>;
  }

  /// GET /quizzes/attempts/{attemptId}
  Future<Map<String, dynamic>> getAttemptResult(String attemptId) async {
    final response = await _apiClient.get(ApiConstants.attemptResult(attemptId));
    return response.data as Map<String, dynamic>;
  }

  /// DELETE /quizzes/{quizId}
  Future<void> deleteQuiz(String quizId) async {
    await _apiClient.delete(ApiConstants.quiz(quizId));
  }
}
