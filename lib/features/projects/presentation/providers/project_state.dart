import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/entities.dart';

part 'project_state.freezed.dart';

/// State for the projects list.
@freezed
abstract class ProjectsState with _$ProjectsState {
  /// Initial state before loading.
  const factory ProjectsState.initial() = ProjectsInitial;

  /// Loading state.
  const factory ProjectsState.loading() = ProjectsLoading;

  /// Loaded state with list of projects.
  const factory ProjectsState.loaded({
    required List<Project> projects,
    @Default(false) bool isLoadingMore,
    @Default(true) bool hasMore,
  }) = ProjectsLoaded;

  /// Error state.
  const factory ProjectsState.error({required String message}) = ProjectsError;
}

/// State for a single project detail.
@freezed
abstract class ProjectDetailState with _$ProjectDetailState {
  /// Initial state before loading.
  const factory ProjectDetailState.initial() = ProjectDetailInitial;

  /// Loading state.
  const factory ProjectDetailState.loading() = ProjectDetailLoading;

  /// Loaded state with project details.
  const factory ProjectDetailState.loaded({
    required Project project,
  }) = ProjectDetailLoaded;

  /// Error state.
  const factory ProjectDetailState.error({required String message}) = ProjectDetailError;
}

/// State for project mutations (create, update, delete).
@freezed
abstract class ProjectMutationState with _$ProjectMutationState {
  /// Idle state.
  const factory ProjectMutationState.idle() = ProjectMutationIdle;

  /// Loading/processing state.
  const factory ProjectMutationState.loading() = ProjectMutationLoading;

  /// Success state.
  const factory ProjectMutationState.success({
    required String message,
    Project? project,
  }) = ProjectMutationSuccess;

  /// Error state.
  const factory ProjectMutationState.error({required String message}) = ProjectMutationError;
}
