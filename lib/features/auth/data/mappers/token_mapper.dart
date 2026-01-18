import '../models/models.dart';
import '../../domain/entities/entities.dart';

/// Extension to convert TokenModel to AuthTokens entity.
extension TokenModelMapper on TokenModel {
  /// Convert this model to domain entity.
  AuthTokens toEntity() {
    return AuthTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresIn: expiresIn,
    );
  }
}

/// Extension to convert RefreshTokenModel to partial AuthTokens.
/// 
/// Note: Refresh endpoint only returns new access token,
/// so we need the existing refresh token.
extension RefreshTokenModelMapper on RefreshTokenModel {
  /// Create AuthTokens with new access token and existing refresh token.
  AuthTokens toEntity({required String existingRefreshToken}) {
    return AuthTokens(
      accessToken: accessToken,
      refreshToken: existingRefreshToken,
      expiresIn: expiresIn,
    );
  }
}