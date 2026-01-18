import 'package:freezed_annotation/freezed_annotation.dart';

// Required for code generation
part 'user_model.freezed.dart';
part 'user_model.g.dart';

/// User model matching your backend's UserResponse schema.
/// 
/// Maps to: TokenResponse.user from /auth/login and /auth/register
@freezed
abstract class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String email,
    
    // Correct placement: @JsonKey goes before 'required'
    @JsonKey(name: 'full_name') required String fullName,
    
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    
    @JsonKey(name: 'is_active') required bool isActive,
    
    @JsonKey(name: 'default_socratic_mode') required bool defaultSocraticMode,
    
    @JsonKey(name: 'created_at') required DateTime createdAt,
    
    @JsonKey(name: 'last_login') DateTime? lastLogin,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) => 
      _$UserModelFromJson(json);
}