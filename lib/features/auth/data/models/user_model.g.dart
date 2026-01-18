// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserModel _$UserModelFromJson(Map<String, dynamic> json) => _UserModel(
  id: json['id'] as String,
  email: json['email'] as String,
  fullName: json['full_name'] as String,
  avatarUrl: json['avatar_url'] as String?,
  isActive: json['is_active'] as bool,
  defaultSocraticMode: json['default_socratic_mode'] as bool,
  createdAt: DateTime.parse(json['created_at'] as String),
  lastLogin: json['last_login'] == null
      ? null
      : DateTime.parse(json['last_login'] as String),
);

Map<String, dynamic> _$UserModelToJson(_UserModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'full_name': instance.fullName,
      'avatar_url': instance.avatarUrl,
      'is_active': instance.isActive,
      'default_socratic_mode': instance.defaultSocraticMode,
      'created_at': instance.createdAt.toIso8601String(),
      'last_login': instance.lastLogin?.toIso8601String(),
    };
