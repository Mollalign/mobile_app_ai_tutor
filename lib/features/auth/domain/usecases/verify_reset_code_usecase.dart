import '../repositories/repositories.dart';

/// Use case for verifying a password reset code.
class VerifyResetCodeUseCase {
  final AuthRepository _repository;

  VerifyResetCodeUseCase(this._repository);

  /// Verify that a reset code is valid.
  /// 
  /// Returns true if the code is valid.
  Future<bool> call({
    required String email,
    required String code,
  }) async {
    return await _repository.verifyResetCode(
      email: email,
      code: code,
    );
  }
}