import '../repositories/repositories.dart';

/// Use case for requesting a password reset code.
class RequestPasswordResetUseCase {
  final AuthRepository _repository;

  RequestPasswordResetUseCase(this._repository);

  /// Request a password reset code to be sent to email.
  /// 
  /// Always succeeds (for security - don't reveal if email exists).
  Future<void> call({required String email}) async {
    await _repository.requestPasswordReset(email: email);
  }
}