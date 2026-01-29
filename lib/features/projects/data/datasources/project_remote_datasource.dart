import '../../../../core/network/network.dart';
import '../models/models.dart';

/// Remote data source for project API calls.
/// 
/// Responsible for:
/// - Making HTTP requests to the backend
/// - Parsing JSON responses into Models
abstract class ProjectRemoteDataSource {
  /// GET /projects
  Future<List<ProjectModel>> getProjects({int skip = 0, int limit = 20});

  /// GET /projects/{id}
  Future<ProjectModel> getProject(String projectId);

  /// POST /projects
  Future<ProjectModel> createProject(ProjectCreateModel data);

  /// PATCH /projects/{id}
  Future<ProjectModel> updateProject(String projectId, ProjectUpdateModel data);

  /// DELETE /projects/{id}
  Future<void> deleteProject(String projectId);
}

/// Implementation of [ProjectRemoteDataSource].
class ProjectRemoteDataSourceImpl implements ProjectRemoteDataSource {
  final ApiClient _apiClient;

  ProjectRemoteDataSourceImpl({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  @override
  Future<List<ProjectModel>> getProjects({int skip = 0, int limit = 20}) async {
    final response = await _apiClient.get(
      '/projects',
      queryParameters: {
        'skip': skip,
        'limit': limit,
      },
    );

    final List<dynamic> data = response.data as List<dynamic>;
    return data
        .map((json) => ProjectModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ProjectModel> getProject(String projectId) async {
    final response = await _apiClient.get('/projects/$projectId');
    return ProjectModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<ProjectModel> createProject(ProjectCreateModel data) async {
    final response = await _apiClient.post(
      '/projects',
      data: data.toJson(),
    );
    return ProjectModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<ProjectModel> updateProject(
    String projectId,
    ProjectUpdateModel data,
  ) async {
    // Only send non-null fields
    final jsonData = <String, dynamic>{};
    if (data.name != null) jsonData['name'] = data.name;
    if (data.description != null) jsonData['description'] = data.description;
    if (data.isArchived != null) jsonData['is_archived'] = data.isArchived;

    final response = await _apiClient.patch(
      '/projects/$projectId',
      data: jsonData,
    );
    return ProjectModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> deleteProject(String projectId) async {
    await _apiClient.delete('/projects/$projectId');
  }
}
