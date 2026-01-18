import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/usecases/usecase.dart';
import 'auth_providers.dart';
import 'password_reset_state.dart';

/// Notifier that manages password reset flow.
class PasswordResetNotifier extends Notifier<PasswordResetState> {
  late final RequestPasswordResetUseCase _requestPasswordResetUseCase;
  late final VerifyResetCodeUseCase _verifyResetCodeUseCase;
  late final ResetPasswordUseCase _resetPasswordUseCase;

  @override
  PasswordResetState build() {
    _requestPasswordResetUseCase = ref.watch(requestPasswordResetUseCaseProvider);
    _verifyResetCodeUseCase = ref.watch(verifyResetCodeUseCaseProvider);
    _resetPasswordUseCase = ref.watch(resetPasswordUseCaseProvider);

    return const PasswordResetState.initial();
  }

  /// Step 1: Request password reset code.
  Future<void> requestCode({required String email}) async {
    state = const PasswordResetState.loading();

    try {
      await _requestPasswordResetUseCase(email: email);
      state = PasswordResetState.codeSent(email: email);
    } catch (e) {
      state = PasswordResetState.error(
        message: _getErrorMessage(e),
        failedStep: PasswordResetStep.requestCode,
      );
    }
  }

  /// Step 2: Verify the reset code.
  Future<void> verifyCode({
    required String email,
    required String code,
  }) async {
    state = const PasswordResetState.loading();

    try {
      final isValid = await _verifyResetCodeUseCase(
        email: email,
        code: code,
      );

      if (isValid) {
        state = PasswordResetState.codeVerified(
          email: email,
          code: code,
        );
      } else {
        state = const PasswordResetState.error(
          message: 'Invalid or expired code. Please try again.',
          failedStep: PasswordResetStep.verifyCode,
        );
      }
    } catch (e) {
      state = PasswordResetState.error(
        message: _getErrorMessage(e),
        failedStep: PasswordResetStep.verifyCode,
      );
    }
  }

  /// Step 3: Reset the password.
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    state = const PasswordResetState.loading();

    try {
      await _resetPasswordUseCase(
        email: email,
        code: code,
        newPassword: newPassword,
      );
      state = const PasswordResetState.success();
    } catch (e) {
      state = PasswordResetState.error(
        message: _getErrorMessage(e),
        failedStep: PasswordResetStep.resetPassword,
      );
    }
  }

  /// Go back to previous step.
  void goBack() {
    state.whenOrNull(
      codeSent: (email) {
        state = const PasswordResetState.initial();
      },
      codeVerified: (email, code) {
        state = PasswordResetState.codeSent(email: email);
      },
      error: (message, failedStep) {
        switch (failedStep) {
          case PasswordResetStep.requestCode:
            state = const PasswordResetState.initial();
            break;
          case PasswordResetStep.verifyCode:
            // Get email from previous attempts - we need to store it
            state = const PasswordResetState.initial();
            break;
          case PasswordResetStep.resetPassword:
            state = const PasswordResetState.initial();
            break;
        }
      },
    );
  }

  /// Reset to initial state.
  void reset() {
    state = const PasswordResetState.initial();
  }

  String _getErrorMessage(dynamic error) {
    if (error is Exception) {
      final message = error.toString();
      if (message.startsWith('Exception: ')) {
        return message.substring(11);
      }
      return message;
    }
    return 'An unexpected error occurred. Please try again.';
  }
}

/// Provider for password reset notifier.
final passwordResetNotifierProvider =
    NotifierProvider<PasswordResetNotifier, PasswordResetState>(() {
  return PasswordResetNotifier();
});