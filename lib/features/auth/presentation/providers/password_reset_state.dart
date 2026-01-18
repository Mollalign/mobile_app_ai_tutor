import 'package:freezed_annotation/freezed_annotation.dart';

part 'password_reset_state.freezed.dart';

/// State for password reset flow.
@freezed
sealed class PasswordResetState with _$PasswordResetState {
  /// Initial state - ready to enter email.
  const factory PasswordResetState.initial() = PasswordResetInitial;

  /// Loading - making API request.
  const factory PasswordResetState.loading() = PasswordResetLoading;

  /// Code sent - ready to enter verification code.
  const factory PasswordResetState.codeSent({
    required String email,
  }) = PasswordResetCodeSent;

  /// Code verified - ready to enter new password.
  const factory PasswordResetState.codeVerified({
    required String email,
    required String code,
  }) = PasswordResetCodeVerified;

  /// Password reset successful.
  const factory PasswordResetState.success() = PasswordResetSuccess;

  /// Error occurred.
  const factory PasswordResetState.error({
    required String message,
    required PasswordResetStep failedStep,
  }) = PasswordResetError;
}

/// Which step failed (for error recovery).
enum PasswordResetStep {
  requestCode,
  verifyCode,
  resetPassword,
}