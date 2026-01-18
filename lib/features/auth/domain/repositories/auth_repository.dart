import '../entities/entities.dart';

/// Abstract contract for authentication operations.
/// 
/// This defines what authentication operations exist.
/// The actual implementation (API calls, storage) is in the data layer.
/// 
/// Why abstract?
/// - Domain layer doesn't know about HTTP, Dio, or APIs
/// - Makes testing easy (mock this interface)
/// - Can swap implementations (REST today, GraphQL tomorrow)
abstract class AuthRepository {
  /// Register a new user.
  /// 
  /// Returns [User] and [AuthTokens] on success.
  /// Throws exception on failure.
  Future<({User user, AuthTokens tokens})> register({
    required String email,
    required String password,
    required String fullName,
  });

  /// Login with email and password.
  /// 
  /// Returns [User] and [AuthTokens] on success.
  /// Throws exception on failure.
  Future<({User user, AuthTokens tokens})> login({
    required String email,
    required String password,
  });

  /// Refresh the access token.
  /// 
  /// Returns new [AuthTokens] on success.
  /// Throws exception if refresh token is invalid.
  Future<AuthTokens> refreshToken();

  /// Get current authenticated user.
  /// 
  /// Returns [User] if authenticated, null otherwise.
  Future<User?> getCurrentUser();

  /// Logout the current user.
  /// 
  /// Clears all stored tokens and user data.
  Future<void> logout();

  /// Request password reset code.
  /// 
  /// Sends a 6-digit code to the email.
  /// Always returns success (security: don't reveal if email exists).
  Future<void> requestPasswordReset({required String email});

  /// Verify password reset code.
  /// 
  /// Returns true if code is valid.
  Future<bool> verifyResetCode({
    required String email,
    required String code,
  });

  /// Reset password with valid code.
  /// 
  /// Sets new password for the account.
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  });

  /// Check if user is currently authenticated.
  /// 
  /// Returns true if valid tokens exist.
  Future<bool> isAuthenticated();
}