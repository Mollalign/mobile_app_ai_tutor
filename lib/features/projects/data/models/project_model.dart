import 'package:freezed_annotation/freezed_annotation.dart';

part 'project_model.freezed.dart';
part 'project_model.g.dart';

/// Project model for API communication.
/// 
/// Maps to backend ProjectResponse schema.
@freezed
abstract class ProjectModel with _$ProjectModel {
  const factory ProjectModel({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    required String name,
    String? description,
    @JsonKey(name: 'is_archived') @Default(false) bool isArchived,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _ProjectModel;

  factory ProjectModel.fromJson(Map<String, dynamic> json) =>
      _$ProjectModelFromJson(json);
}

/// Request model for creating a project.
@freezed
abstract class ProjectCreateModel with _$ProjectCreateModel {
  const factory ProjectCreateModel({
    required String name,
    String? description,
  }) = _ProjectCreateModel;

  factory ProjectCreateModel.fromJson(Map<String, dynamic> json) =>
      _$ProjectCreateModelFromJson(json);
}

/// Request model for updating a project.
@freezed
abstract class ProjectUpdateModel with _$ProjectUpdateModel {
  const factory ProjectUpdateModel({
    String? name,
    String? description,
    @JsonKey(name: 'is_archived') bool? isArchived,
  }) = _ProjectUpdateModel;

  factory ProjectUpdateModel.fromJson(Map<String, dynamic> json) =>
      _$ProjectUpdateModelFromJson(json);
}
