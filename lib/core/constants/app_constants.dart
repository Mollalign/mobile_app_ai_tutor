/// Application-wide constants.
class AppConstants {
  AppConstants._();

  // ============================================================
  // App Info
  // ============================================================
  
  static const String appName = 'Informatics Tutor';
  static const String appVersion = '1.0.0';

  // ============================================================
  // Validation Rules (matching your backend)
  // ============================================================
  
  /// Minimum password length (your backend requires 8)
  static const int minPasswordLength = 8;
  
  /// Maximum password length
  static const int maxPasswordLength = 100;
  
  /// Minimum name length
  static const int minNameLength = 2;
  
  /// Maximum name length
  static const int maxNameLength = 100;
  
  /// Password reset code length
  static const int resetCodeLength = 6;

  // ============================================================
  // Token Configuration (matching your backend)
  // ============================================================
  
  /// Access token expiry in seconds (your backend: 60 minutes = 3600 seconds)
  static const int accessTokenExpirySeconds = 3600;
  
  /// Refresh token expiry in days (your backend: 7 days)
  static const int refreshTokenExpiryDays = 7;
  
  /// Buffer time before token expires to trigger refresh (5 minutes)
  /// This prevents making API calls with a token that's about to expire
  static const int tokenRefreshBuffer = 300; // 5 minutes in seconds
}