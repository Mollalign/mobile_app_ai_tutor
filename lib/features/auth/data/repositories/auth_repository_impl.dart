import 'package:mobile/features/auth/data/models/token_model.dart';
import 'package:mobile/features/auth/data/models/user_model.dart';

import '../../../../core/storage/storage.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/repositories.dart';
import '../datasources/datasources.dart';
import '../mappers/mappers.dart';

/// Implementation of [AuthRepository].
/// 
/// Coordinates between:
/// - Remote data source (API calls)
/// - Secure storage (token persistence)
/// - Model/Entity mapping
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final SecureStorage _storage;

  AuthRepositoryImpl({
    AuthRemoteDataSource? remoteDataSource,
    SecureStorage? storage,
  })  : _remoteDataSource = remoteDataSource ?? AuthRemoteDataSourceImpl(),
        _storage = storage ?? SecureStorage();

  // ============================================================
  // Authentication
  // ============================================================

  @override
  Future<({User user, AuthTokens tokens})> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    // 1. Make API call
    final tokenModel = await _remoteDataSource.register(
      email: email,
      password: password,
      fullName: fullName,
    );

    // 2. Save tokens to secure storage
    await _saveTokens(tokenModel);

    // 3. Cache user data
    await _storage.saveUserData(tokenModel.user.toJson());

    // 4. Convert to entities and return
    return (
      user: tokenModel.user.toEntity(),
      tokens: tokenModel.toEntity(),
    );
  }

  @override
  Future<({User user, AuthTokens tokens})> login({
    required String email,
    required String password,
  }) async {
    // 1. Make API call
    final tokenModel = await _remoteDataSource.login(
      email: email,
      password: password,
    );

    // 2. Save tokens to secure storage
    await _saveTokens(tokenModel);

    // 3. Cache user data
    await _storage.saveUserData(tokenModel.user.toJson());

    // 4. Convert to entities and return
    return (
      user: tokenModel.user.toEntity(),
      tokens: tokenModel.toEntity(),
    );
  }

  @override
  Future<AuthTokens> refreshToken() async {
    // 1. Get existing refresh token
    final refreshToken = await _storage.getRefreshToken();
    
    if (refreshToken == null) {
      throw Exception('No refresh token available');
    }

    // 2. Make API call
    final refreshModel = await _remoteDataSource.refreshToken(refreshToken);

    // 3. Update stored access token
    await _storage.updateAccessToken(
      accessToken: refreshModel.accessToken,
      expiresIn: refreshModel.expiresIn,
    );

    // 4. Return entity with existing refresh token
    return refreshModel.toEntity(existingRefreshToken: refreshToken);
  }

  @override
  Future<User?> getCurrentUser() async {
    // First, check if we have a valid token
    final hasValidToken = await _storage.hasValidAccessToken();
    
    if (!hasValidToken) {
      // Try to use cached user data
      final cachedData = await _storage.getUserData();
      if (cachedData != null) {
        try {
          final userModel = UserModel.fromJson(cachedData);
          return userModel.toEntity();
        } catch (_) {
          // Corrupted cache, ignore
        }
      }
      return null;
    }

    try {
      // Fetch fresh user data from API
      final userModel = await _remoteDataSource.getCurrentUser();
      
      // Update cache
      await _storage.saveUserData(userModel.toJson());
      
      return userModel.toEntity();
    } catch (_) {
      // API call failed, try cache
      final cachedData = await _storage.getUserData();
      if (cachedData != null) {
        try {
          final userModel = UserModel.fromJson(cachedData);
          return userModel.toEntity();
        } catch (_) {
          return null;
        }
      }
      return null;
    }
  }

  @override
  Future<void> logout() async {
    // Clear all stored authentication data
    await _storage.clearAll();
  }

  // ============================================================
  // Password Reset
  // ============================================================

  @override
  Future<void> requestPasswordReset({required String email}) async {
    await _remoteDataSource.requestPasswordReset(email);
    // We don't need to do anything with the response
    // Backend always returns success for security
  }

  @override
  Future<bool> verifyResetCode({
    required String email,
    required String code,
  }) async {
    try {
      final response = await _remoteDataSource.verifyResetCode(
        email: email,
        code: code,
      );
      return response.success;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    await _remoteDataSource.resetPassword(
      email: email,
      code: code,
      newPassword: newPassword,
    );
  }

  // ============================================================
  // Auth Status
  // ============================================================

  @override
  Future<bool> isAuthenticated() async {
    // Check if we have a valid access token
    final hasValidToken = await _storage.hasValidAccessToken();
    
    if (hasValidToken) {
      return true;
    }

    // Check if we have a refresh token to try
    final hasRefreshToken = await _storage.hasRefreshToken();
    
    if (!hasRefreshToken) {
      return false;
    }

    // Try to refresh the token
    try {
      await refreshToken();
      return true;
    } catch (_) {
      // Refresh failed, user is not authenticated
      await _storage.clearAll();
      return false;
    }
  }

  // ============================================================
  // Private Helpers
  // ============================================================

  /// Save tokens from login/register response.
  Future<void> _saveTokens(TokenModel tokenModel) async {
    await _storage.saveTokens(
      accessToken: tokenModel.accessToken,
      refreshToken: tokenModel.refreshToken,
      expiresIn: tokenModel.expiresIn,
    );
  }
}