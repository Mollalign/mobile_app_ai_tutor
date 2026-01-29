import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/repositories.dart';
import 'project_state.dart';
import 'projects_notifier.dart';

// ============================================================
// Notifier using ChangeNotifier for family support
// ============================================================

/// Notifier for managing a single project's state.
class ProjectDetailChangeNotifier extends ChangeNotifier {
  final ProjectRepository _repository;
  final String projectId;
  bool _disposed = false;
  
  ProjectDetailState _state = const ProjectDetailState.initial();
  ProjectDetailState get state => _state;

  ProjectDetailChangeNotifier({
    required ProjectRepository repository,
    required this.projectId,
  }) : _repository = repository;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (_disposed) return;

    final phase = SchedulerBinding.instance.schedulerPhase;
    final shouldDefer = phase == SchedulerPhase.persistentCallbacks ||
        phase == SchedulerPhase.midFrameMicrotasks;

    if (shouldDefer) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (!_disposed) {
          super.notifyListeners();
        }
      });
      return;
    }

    super.notifyListeners();
  }

  /// Load project details.
  Future<void> loadProject() async {
    _state = const ProjectDetailState.loading();
    notifyListeners();

    try {
      debugPrint('Loading project: projectId=$projectId');
      
      final project = await _repository.getProject(projectId).timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw TimeoutException('Request timed out after 60 seconds');
        },
      );
      
      debugPrint('Loaded project: ${project.name}');
      
      _state = ProjectDetailState.loaded(project: project);
    } catch (e, stackTrace) {
      debugPrint('Error loading project: $e');
      debugPrint('Stack trace: $stackTrace');
      _state = ProjectDetailState.error(message: _getErrorMessage(e));
    } finally {
      notifyListeners();
    }
  }

  /// Update project.
  Future<void> updateProject({
    String? name,
    String? description,
    bool? isArchived,
  }) async {
    final currentProject = _state.mapOrNull(
      loaded: (s) => s.project,
    );

    if (currentProject == null) return;

    _state = const ProjectDetailState.loading();
    notifyListeners();

    try {
      final updatedProject = await _repository.updateProject(
        projectId: projectId,
        name: name,
        description: description,
        isArchived: isArchived,
      );
      _state = ProjectDetailState.loaded(project: updatedProject);
    } catch (e) {
      // Restore previous state on error
      _state = ProjectDetailState.loaded(project: currentProject);
    }
    notifyListeners();
  }

  /// Delete project.
  Future<bool> deleteProject() async {
    try {
      await _repository.deleteProject(projectId);
      return true;
    } catch (e) {
      return false;
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
    return 'Failed to load project. Please try again.';
  }
}

// ============================================================
// Provider
// ============================================================

/// Provider for a specific project's details.
final projectDetailNotifierProvider =
    Provider.family.autoDispose<ProjectDetailChangeNotifier, String>(
  (ref, projectId) {
    final repository = ref.watch(projectRepositoryProvider);
    final notifier = ProjectDetailChangeNotifier(
      repository: repository,
      projectId: projectId,
    );
    ref.onDispose(() => notifier.dispose());
    return notifier;
  },
);
