import '../models/models.dart';
import '../../domain/entities/entities.dart';

/// Extension to convert UserModel to User entity.
extension UserModelMapper on UserModel {
  /// Convert this model to a domain entity.
  User toEntity() {
    return User(
      id: id,
      email: email,
      fullName: fullName,
      avatarUrl: avatarUrl,
      isActive: isActive,
      defaultSocraticMode: defaultSocraticMode,
      createdAt: createdAt,
      lastLogin: lastLogin,
    );
  }
}

/// Extension to convert User entity to UserModel.
extension UserEntityMapper on User {
  /// Convert this entity to a data model.
  /// 
  /// Useful when you need to cache user data as JSON.
  UserModel toModel() {
    return UserModel(
      id: id,
      email: email,
      fullName: fullName,
      avatarUrl: avatarUrl,
      isActive: isActive,
      defaultSocraticMode: defaultSocraticMode,
      createdAt: createdAt,
      lastLogin: lastLogin,
    );
  }
}