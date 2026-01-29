// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProjectModel _$ProjectModelFromJson(Map<String, dynamic> json) =>
    _ProjectModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      isArchived: json['is_archived'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$ProjectModelToJson(_ProjectModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'name': instance.name,
      'description': instance.description,
      'is_archived': instance.isArchived,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

_ProjectCreateModel _$ProjectCreateModelFromJson(Map<String, dynamic> json) =>
    _ProjectCreateModel(
      name: json['name'] as String,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$ProjectCreateModelToJson(_ProjectCreateModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
    };

_ProjectUpdateModel _$ProjectUpdateModelFromJson(Map<String, dynamic> json) =>
    _ProjectUpdateModel(
      name: json['name'] as String?,
      description: json['description'] as String?,
      isArchived: json['is_archived'] as bool?,
    );

Map<String, dynamic> _$ProjectUpdateModelToJson(_ProjectUpdateModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'is_archived': instance.isArchived,
    };
