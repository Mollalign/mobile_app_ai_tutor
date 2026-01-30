import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/repositories.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/repositories.dart';
import 'project_state.dart';

/// Notifier that manages the projects list state.
class ProjectsNotifier extends Notifier<ProjectsState> {
  late final ProjectRepository _repository;
  
  static const int _pageSize = 20;
  int _currentPage = 0;

  @override
  ProjectsState build() {
    _repository = ref.watch(projectRepositoryProvider);
    // Auto-load projects on initialization
    _loadProjects();
    return const ProjectsState.initial();
  }

  /// Load projects (initial load or refresh).
  Future<void> loadProjects({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 0;
    }
    await _loadProjects();
  }

  Future<void> _loadProjects() async {
    state = const ProjectsState.loading();

    try {
      final projects = await _repository.getProjects(
        skip: 0,
        limit: _pageSize,
      );
      
      _currentPage = 1;
      
      state = ProjectsState.loaded(
        projects: projects,
        hasMore: projects.length >= _pageSize,
      );
    } catch (e) {
      state = ProjectsState.error(message: _getErrorMessage(e));
    }
  }

  /// Load more projects (pagination).
  Future<void> loadMore() async {
    final currentState = state;
    if (currentState is! ProjectsLoaded) return;
    if (currentState.isLoadingMore || !currentState.hasMore) return;

    state = currentState.copyWith(isLoadingMore: true);

    try {
      final moreProjects = await _repository.getProjects(
        skip: _currentPage * _pageSize,
        limit: _pageSize,
      );

      _currentPage++;

      state = ProjectsLoaded(
        projects: [...currentState.projects, ...moreProjects],
        hasMore: moreProjects.length >= _pageSize,
        isLoadingMore: false,
      );
    } catch (e) {
      state = currentState.copyWith(isLoadingMore: false);
    }
  }

  /// Add a newly created project to the list.
  void addProject(Project project) {
    final currentState = state;
    if (currentState is ProjectsLoaded) {
      state = currentState.copyWith(
        projects: [project, ...currentState.projects],
      );
    }
  }

  /// Update a project in the list.
  void updateProject(Project updatedProject) {
    final currentState = state;
    if (currentState is ProjectsLoaded) {
      final updatedList = currentState.projects.map((p) {
        return p.id == updatedProject.id ? updatedProject : p;
      }).toList();
      state = currentState.copyWith(projects: updatedList);
    }
  }

  /// Remove a project from the list.
  void removeProject(String projectId) {
    final currentState = state;
    if (currentState is ProjectsLoaded) {
      final updatedList = currentState.projects
          .where((p) => p.id != projectId)
          .toList();
      state = currentState.copyWith(projects: updatedList);
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error is Exception) {
      final message = error.toString();
      if (message.startsWith('Exception: ')) {
        return message.substring(11);
      }
      return message;
    }
    return 'Failed to load projects. Please try again.';
  }
}

/// Notifier that manages project mutations (create, update, delete).
class ProjectMutationNotifier extends Notifier<ProjectMutationState> {
  late final ProjectRepository _repository;

  @override
  ProjectMutationState build() {
    _repository = ref.watch(projectRepositoryProvider);
    return const ProjectMutationState.idle();
  }

  /// Create a new project.
  Future<Project?> createProject({
    required String name,
    String? description,
  }) async {
    state = const ProjectMutationState.loading();

    try {
      final project = await _repository.createProject(
        name: name,
        description: description,
      );

      // Add to projects list
      ref.read(projectsNotifierProvider.notifier).addProject(project);

      state = ProjectMutationState.success(
        message: 'Project created successfully',
        project: project,
      );

      return project;
    } catch (e) {
      state = ProjectMutationState.error(message: _getErrorMessage(e));
      return null;
    }
  }

  /// Update an existing project.
  Future<Project?> updateProject({
    required String projectId,
    String? name,
    String? description,
    bool? isArchived,
  }) async {
    state = const ProjectMutationState.loading();

    try {
      final project = await _repository.updateProject(
        projectId: projectId,
        name: name,
        description: description,
        isArchived: isArchived,
      );

      // Update in projects list
      ref.read(projectsNotifierProvider.notifier).updateProject(project);

      state = ProjectMutationState.success(
        message: 'Project updated successfully',
        project: project,
      );

      return project;
    } catch (e) {
      state = ProjectMutationState.error(message: _getErrorMessage(e));
      return null;
    }
  }

  /// Delete a project.
  Future<bool> deleteProject(String projectId) async {
    state = const ProjectMutationState.loading();

    try {
      await _repository.deleteProject(projectId);

      // Remove from projects list
      ref.read(projectsNotifierProvider.notifier).removeProject(projectId);

      state = const ProjectMutationState.success(
        message: 'Project deleted successfully',
      );

      return true;
    } catch (e) {
      state = ProjectMutationState.error(message: _getErrorMessage(e));
      return false;
    }
  }

  /// Archive/unarchive a project.
  Future<Project?> toggleArchive(String projectId, {required bool archive}) {
    return updateProject(projectId: projectId, isArchived: archive);
  }

  /// Reset to idle state.
  void reset() {
    state = const ProjectMutationState.idle();
  }

  String _getErrorMessage(dynamic error) {
    if (error is Exception) {
      final message = error.toString();
      if (message.startsWith('Exception: ')) {
        return message.substring(11);
      }
      return message;
    }
    return 'Operation failed. Please try again.';
  }
}

// ============================================================
// Providers
// ============================================================

/// Provider for the project repository.
final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  return ProjectRepositoryImpl();
});

/// Provider for the projects list notifier.
final projectsNotifierProvider =
    NotifierProvider<ProjectsNotifier, ProjectsState>(() {
  return ProjectsNotifier();
});

/// Provider for project mutations.
final projectMutationNotifierProvider =
    NotifierProvider<ProjectMutationNotifier, ProjectMutationState>(() {
  return ProjectMutationNotifier();
});

/// Simple notifier for view mode (grid or list).
class ProjectsViewModeNotifier extends Notifier<bool> {
  @override
  bool build() => true;

  void toggle() {
    state = !state;
  }

  void setGridView() {
    state = true;
  }

  void setListView() {
    state = false;
  }
}

/// Provider for view mode (grid or list).
final projectsViewModeProvider = NotifierProvider<ProjectsViewModeNotifier, bool>(() {
  return ProjectsViewModeNotifier();
});
