import 'package:freezed_annotation/freezed_annotation.dart';

part 'refresh_token_model.freezed.dart';
part 'refresh_token_model.g.dart';

/// Response from token refresh endpoint.
/// 
/// Returned from: /auth/refresh
/// Note: This only returns a new access token, not a new refresh token.
@freezed
abstract class RefreshTokenModel with _$RefreshTokenModel {
  const factory RefreshTokenModel({
    @JsonKey(name: 'access_token') required String accessToken,
    @JsonKey(name: 'token_type') required String tokenType,
    @JsonKey(name: 'expires_in') required int expiresIn,
  }) = _RefreshTokenModel;

  factory RefreshTokenModel.fromJson(Map<String, dynamic> json) => 
      _$RefreshTokenModelFromJson(json);
}