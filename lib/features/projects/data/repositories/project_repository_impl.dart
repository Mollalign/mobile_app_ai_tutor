import '../../domain/entities/entities.dart';
import '../../domain/repositories/repositories.dart';
import '../datasources/datasources.dart';
import '../mappers/mappers.dart';
import '../models/models.dart';

/// Implementation of [ProjectRepository].
/// 
/// Coordinates between:
/// - Remote data source (API calls)
/// - Model/Entity mapping
class ProjectRepositoryImpl implements ProjectRepository {
  final ProjectRemoteDataSource _remoteDataSource;

  ProjectRepositoryImpl({ProjectRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? ProjectRemoteDataSourceImpl();

  @override
  Future<List<Project>> getProjects({int skip = 0, int limit = 20}) async {
    final models = await _remoteDataSource.getProjects(
      skip: skip,
      limit: limit,
    );
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Project> getProject(String projectId) async {
    final model = await _remoteDataSource.getProject(projectId);
    return model.toEntity();
  }

  @override
  Future<Project> createProject({
    required String name,
    String? description,
  }) async {
    final createModel = ProjectCreateModel(
      name: name,
      description: description,
    );
    final model = await _remoteDataSource.createProject(createModel);
    return model.toEntity();
  }

  @override
  Future<Project> updateProject({
    required String projectId,
    String? name,
    String? description,
    bool? isArchived,
  }) async {
    final updateModel = ProjectUpdateModel(
      name: name,
      description: description,
      isArchived: isArchived,
    );
    final model = await _remoteDataSource.updateProject(projectId, updateModel);
    return model.toEntity();
  }

  @override
  Future<void> deleteProject(String projectId) async {
    await _remoteDataSource.deleteProject(projectId);
  }

  @override
  Future<Project> toggleArchive(String projectId, {required bool isArchived}) {
    return updateProject(projectId: projectId, isArchived: isArchived);
  }
}
