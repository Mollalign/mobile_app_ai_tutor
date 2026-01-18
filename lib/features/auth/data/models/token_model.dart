import 'package:freezed_annotation/freezed_annotation.dart';
import 'user_model.dart';

part 'token_model.freezed.dart';
part 'token_model.g.dart';

/// Token response model matching your backend's TokenResponse schema.
/// 
/// Returned from: /auth/login, /auth/register
@freezed
abstract class TokenModel with _$TokenModel {
  const factory TokenModel({
    /// JWT access token (short-lived, 60 minutes)
    @JsonKey(name: 'access_token') required String accessToken,
    
    /// JWT refresh token (long-lived, 7 days)
    @JsonKey(name: 'refresh_token') required String refreshToken,
    
    /// Token type (always "bearer")
    @JsonKey(name: 'token_type') required String tokenType,
    
    /// Seconds until access token expires
    @JsonKey(name: 'expires_in') required int expiresIn,
    
    /// User data included in response
    required UserModel user,
  }) = _TokenModel;

  factory TokenModel.fromJson(Map<String, dynamic> json) => 
      _$TokenModelFromJson(json);
}