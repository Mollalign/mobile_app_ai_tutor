// API configuration constants that match FastAPI backend.

class ApiConstants {
  // Private constructor - this class should not be instantiated
  ApiConstants._();

  // ============================================================
  // Base Configuration
  // ============================================================

  // Base URL for  backend
  // For Android emulator use: 10.0.2.2 (maps to host localhost)
  // For iOS simulator use: localhost or 127.0.0.1
  // For real device: use your machine's IP or deployed URL
  static const String baseUrl = 'http://10.157.176.46:8000';

  // API version prefix
  static const String apiPrefix = '/api/v1';

  // Fill Api base URL
  static String get apiBaseUrl => '$baseUrl$apiPrefix';

  // ============================================================
  // Auth Endpoints
  // ============================================================

  /// POST - Register new user
  /// Request: { email, password, full_name }
  /// Response: TokenResponse with access_token, refresh_token, user
  static String get register => '$apiBaseUrl/auth/register';
  
  /// POST - Login user
  /// Request: { email, password }
  /// Response: TokenResponse
  static String get login => '$apiBaseUrl/auth/login';

  /// POST - Refresh access token
  /// Request: { refresh_token }
  /// Response: { access_token, token_type, expires_in }
  static String get refreshToken => '$apiBaseUrl/auth/refresh';
  
  /// GET - Get current user info (requires Bearer token)
  /// Response: UserResponse
  static String get me => '$apiBaseUrl/auth/me';
  
  /// POST - Request password reset code
  /// Request: { email }
  /// Response: { message, success }
  static String get forgotPassword => '$apiBaseUrl/auth/forgot-password';
  
  /// POST - Verify reset code is valid
  /// Request: { email, code }
  /// Response: { message, success }
  static String get verifyResetCode => '$apiBaseUrl/auth/verify-reset-code';
  
  /// POST - Reset password with code
  /// Request: { email, code, new_password }
  /// Response: { message, success }
  static String get resetPassword => '$apiBaseUrl/auth/reset-password';
  
  // ============================================================
  // Timeouts (in milliseconds)
  // ============================================================
  
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000;    // 30 seconds
}