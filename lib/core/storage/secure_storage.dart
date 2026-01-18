import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/constants.dart';

/// Secure storage wrapper for handling sensitive data like tokens.

class SecureStorage {
  // Private constructor for singleton pattern
  SecureStorage._internal();
  
  // Singleton instance
  static final SecureStorage _instance = SecureStorage._internal();
  
  // Factory constructor returns the singleton
  factory SecureStorage() => _instance;
  
  // Updated for 2026 standards
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      // encryptedSharedPreferences is removed; custom ciphers are now used automatically
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );


  // ============================================================
  // Token Operations
  // ============================================================

  /// Save both access and refresh tokens.
  /// 
  /// Also saves the expiration timestamp for proactive refresh.
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required int expiresIn, // seconds until expiry
  }) async {
    // Calculate expiration timestamp
    final expiresAt = DateTime.now()
        .add(Duration(seconds: expiresIn))
        .millisecondsSinceEpoch;

    await Future.wait([
      _storage.write(
        key: StorageConstants.accessToken,
        value: accessToken,
      ),
      _storage.write(
        key: StorageConstants.refreshToken,
        value: refreshToken,
      ),
      _storage.write(
        key: StorageConstants.tokenExpiresAt,
        value: expiresAt.toString(),
      ),
    ]);
  }

  /// Get the access token, or null if not stored.
  Future<String?> getAccessToken() async {
    return await _storage.read(key: StorageConstants.accessToken);
  }

  /// Get the refresh token, or null if not stored.
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: StorageConstants.refreshToken);
  }

  /// Check if access token exists and is not expired.
  /// 
  /// Returns true if token exists AND has more than [bufferSeconds] 
  /// remaining before expiry.
  Future<bool> hasValidAccessToken({
    int bufferSeconds = 300, // 5 minutes buffer
  }) async {
    final token = await getAccessToken();
    if (token == null) return false;

    final expiresAtStr = await _storage.read(
      key: StorageConstants.tokenExpiresAt,
    );
    if (expiresAtStr == null) return false;

    final expiresAt = int.tryParse(expiresAtStr);
    if (expiresAt == null) return false;

    final now = DateTime.now().millisecondsSinceEpoch;
    final bufferMs = bufferSeconds * 1000;

    // Token is valid if current time + buffer is before expiry
    return now + bufferMs < expiresAt;
  }

  /// Check if we have a refresh token stored.
  Future<bool> hasRefreshToken() async {
    final token = await getRefreshToken();
    return token != null && token.isNotEmpty;
  }

  /// Update only the access token (after refresh).
  /// 
  /// Called when we use the refresh token to get a new access token.
  Future<void> updateAccessToken({
    required String accessToken,
    required int expiresIn,
  }) async {
    final expiresAt = DateTime.now()
        .add(Duration(seconds: expiresIn))
        .millisecondsSinceEpoch;

    await Future.wait([
      _storage.write(
        key: StorageConstants.accessToken,
        value: accessToken,
      ),
      _storage.write(
        key: StorageConstants.tokenExpiresAt,
        value: expiresAt.toString(),
      ),
    ]);
  }

  // ============================================================
  // User Data Operations
  // ============================================================

  /// Save user data as JSON string.
  /// 
  /// [userData] should be a Map that can be JSON encoded.
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    final jsonString = jsonEncode(userData);
    await _storage.write(
      key: StorageConstants.userData,
      value: jsonString,
    );
  }

  /// Get cached user data.
  /// 
  /// Returns null if no user data is stored.
  Future<Map<String, dynamic>?> getUserData() async {
    final jsonString = await _storage.read(key: StorageConstants.userData);
    if (jsonString == null) return null;

    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      // Corrupted data, clear it
      await _storage.delete(key: StorageConstants.userData);
      return null;
    }
  }
  

  // ============================================================
  // Cleanup Operations
  // ============================================================

  /// Clear all authentication data (logout).
  /// 
  /// Removes tokens and user data.
  Future<void> clearAll() async {
    await Future.wait([
      _storage.delete(key: StorageConstants.accessToken),
      _storage.delete(key: StorageConstants.refreshToken),
      _storage.delete(key: StorageConstants.tokenExpiresAt),
      _storage.delete(key: StorageConstants.userData),
      _storage.delete(key: StorageConstants.userId),
    ]);
  }

  /// Clear only tokens (keeps user data cache).
  Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: StorageConstants.accessToken),
      _storage.delete(key: StorageConstants.refreshToken),
      _storage.delete(key: StorageConstants.tokenExpiresAt),
    ]);
  }
}