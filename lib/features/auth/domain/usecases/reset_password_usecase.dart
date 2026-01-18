import '../repositories/repositories.dart';

/// Use case for resetting password with a valid code.
class ResetPasswordUseCase {
  final AuthRepository _repository;

  ResetPasswordUseCase(this._repository);

  /// Reset the password using a valid reset code.
  Future<void> call({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    await _repository.resetPassword(
      email: email,
      code: code,
      newPassword: newPassword,
    );
  }
}