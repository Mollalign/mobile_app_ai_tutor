import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/entities.dart';

part 'auth_state.freezed.dart';

/// Represents the authentication state of the application.
/// 
/// Uses sealed class pattern for exhaustive state handling.
@freezed
sealed class AuthState with _$AuthState {
  /// Initial state - checking if user is logged in.
  const factory AuthState.initial() = AuthStateInitial;

  /// Currently checking authentication status.
  const factory AuthState.loading() = AuthStateLoading;

  /// User is authenticated.
  const factory AuthState.authenticated({
    required User user,
  }) = AuthStateAuthenticated;

  /// User is not authenticated.
  const factory AuthState.unauthenticated() = AuthStateUnauthenticated;

  /// Authentication error occurred.
  const factory AuthState.error({
    required String message,
  }) = AuthStateError;
}