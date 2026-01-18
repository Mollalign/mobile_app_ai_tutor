import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_tokens.freezed.dart';

/// Authentication tokens entity.
/// 
/// Represents the tokens needed for API authentication.
@freezed
abstract class AuthTokens with _$AuthTokens {
  const AuthTokens._();

  const factory AuthTokens({
    required String accessToken,
    required String refreshToken,
    required int expiresIn,
  }) = _AuthTokens;

  /// Calculate when the access token expires.
  DateTime get expiresAt => DateTime.now().add(Duration(seconds: expiresIn));

  /// Check if token is about to expire (within buffer time).
  bool isExpiringSoon({int bufferSeconds = 300}) {
    final now = DateTime.now();
    final bufferTime = Duration(seconds: bufferSeconds);
    return now.add(bufferTime).isAfter(expiresAt);
  }
}