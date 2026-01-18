/// Keys used for secure storage.
/// 
/// These keys are used to store and retrieve sensitive data
/// from flutter_secure_storage.
class StorageConstants {
  StorageConstants._();

  // ============================================================
  // Token Storage Keys
  // ============================================================
  
  /// Key for storing JWT access token
  static const String accessToken = 'access_token';
  
  /// Key for storing JWT refresh token
  static const String refreshToken = 'refresh_token';
  
  /// Key for storing token expiration timestamp
  static const String tokenExpiresAt = 'token_expires_at';
  
  // ============================================================
  // User Storage Keys
  // ============================================================
  
  /// Key for storing cached user data (JSON string)
  static const String userData = 'user_data';
  
  /// Key for storing user ID
  static const String userId = 'user_id';
}