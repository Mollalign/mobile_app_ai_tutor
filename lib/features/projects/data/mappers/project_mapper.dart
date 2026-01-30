import '../../domain/entities/entities.dart';
import '../models/models.dart';

/// Extension to convert ProjectModel to Project entity.
extension ProjectModelMapper on ProjectModel {
  Project toEntity() {
    return Project(
      id: id,
      userId: userId,
      name: name,
      description: description,
      isArchived: isArchived,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

/// Extension to convert Project entity to update model.
extension ProjectEntityMapper on Project {
  ProjectUpdateModel toUpdateModel({
    String? name,
    String? description,
    bool? isArchived,
  }) {
    return ProjectUpdateModel(
      name: name,
      description: description,
      isArchived: isArchived,
    );
  }
}
