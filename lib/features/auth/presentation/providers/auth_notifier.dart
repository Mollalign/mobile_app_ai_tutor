import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/auth/domain/usecases/usecase.dart';

import 'auth_state.dart';
import 'auth_providers.dart';

/// Notifier that manages authentication state.
/// 
/// Responsibilities:
/// - Check auth status on startup
/// - Handle login/register/logout
/// - Update state based on operations
class AuthNotifier extends Notifier<AuthState> {
  late final LoginUseCase _loginUseCase;
  late final RegisterUseCase _registerUseCase;
  late final LogoutUseCase _logoutUseCase;
  late final GetCurrentUserUseCase _getCurrentUserUseCase;
  late final CheckAuthStatusUseCase _checkAuthStatusUseCase;

  @override
  AuthState build() {
    // Initialize use cases from providers
    _loginUseCase = ref.watch(loginUseCaseProvider);
    _registerUseCase = ref.watch(registerUseCaseProvider);
    _logoutUseCase = ref.watch(logoutUseCaseProvider);
    _getCurrentUserUseCase = ref.watch(getCurrentUserUseCaseProvider);
    _checkAuthStatusUseCase = ref.watch(checkAuthStatusUseCaseProvider);

    // Start by checking auth status
    _checkAuthStatus();

    // Return initial state
    return const AuthState.initial();
  }

  // ============================================================
  // Public Methods (called from UI)
  // ============================================================

  /// Check if user is authenticated (called on app startup).
  Future<void> checkAuthStatus() async {
    await _checkAuthStatus();
  }

  /// Login with email and password.
  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AuthState.loading();

    try {
      final result = await _loginUseCase(
        email: email,
        password: password,
      );

      state = AuthState.authenticated(user: result.user);
    } catch (e) {
      state = AuthState.error(message: _getErrorMessage(e));
    }
  }

  /// Register a new user.
  Future<void> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    state = const AuthState.loading();

    try {
      final result = await _registerUseCase(
        email: email,
        password: password,
        fullName: fullName,
      );

      state = AuthState.authenticated(user: result.user);
    } catch (e) {
      state = AuthState.error(message: _getErrorMessage(e));
    }
  }

  /// Logout the current user.
  Future<void> logout() async {
    state = const AuthState.loading();

    try {
      await _logoutUseCase();
      state = const AuthState.unauthenticated();
    } catch (e) {
      // Even if logout fails, treat as logged out
      state = const AuthState.unauthenticated();
    }
  }

  /// Clear error and go back to unauthenticated state.
  void clearError() {
    state = const AuthState.unauthenticated();
  }

  // ============================================================
  // Private Methods
  // ============================================================

  /// Check authentication status on startup.
  Future<void> _checkAuthStatus() async {
    try {
      final isAuthenticated = await _checkAuthStatusUseCase();

      if (isAuthenticated) {
        final user = await _getCurrentUserUseCase();
        if (user != null) {
          state = AuthState.authenticated(user: user);
        } else {
          state = const AuthState.unauthenticated();
        }
      } else {
        state = const AuthState.unauthenticated();
      }
    } catch (e) {
      state = const AuthState.unauthenticated();
    }
  }

  /// Extract user-friendly error message.
  String _getErrorMessage(dynamic error) {
    if (error is Exception) {
      final message = error.toString();
      
      // Remove "Exception: " prefix if present
      if (message.startsWith('Exception: ')) {
        return message.substring(11);
      }
      
      return message;
    }
    
    return 'An unexpected error occurred. Please try again.';
  }
}

final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});

// ============================================================
// Provider
// ============================================================

/// Provider for auth notifier.
/// 
/// Usage:
///
/// // Read state
/// final authState = ref.watch(authNotifierProvider);
/// 
/// // Call methods
/// ref.read(authNotifierProvider.notifier).login(email: x, password: y);
/// 