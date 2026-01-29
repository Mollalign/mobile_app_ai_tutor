import '../entities/entities.dart';

/// Abstract contract for project operations.
/// 
/// Defines what project operations exist.
/// The actual implementation is in the data layer.
abstract class ProjectRepository {
  /// Get all projects for the current user.
  /// 
  /// Returns list of [Project] ordered by most recently updated.
  /// Supports pagination with [skip] and [limit].
  Future<List<Project>> getProjects({
    int skip = 0,
    int limit = 20,
  });

  /// Get a single project by ID.
  /// 
  /// Returns [Project] if found.
  /// Throws exception if not found or not owned by user.
  Future<Project> getProject(String projectId);

  /// Create a new project.
  /// 
  /// Returns the created [Project].
  Future<Project> createProject({
    required String name,
    String? description,
  });

  /// Update an existing project.
  /// 
  /// Only provided fields will be updated.
  /// Returns the updated [Project].
  Future<Project> updateProject({
    required String projectId,
    String? name,
    String? description,
    bool? isArchived,
  });

  /// Delete a project.
  /// 
  /// This permanently removes the project and all related data.
  Future<void> deleteProject(String projectId);

  /// Archive/unarchive a project.
  /// 
  /// Convenience method that calls [updateProject] with isArchived.
  Future<Project> toggleArchive(String projectId, {required bool isArchived});
}
