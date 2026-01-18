import '../entities/entities.dart';
import '../repositories/repositories.dart';

/// Use case for user registration.
class RegisterUseCase {
  final AuthRepository _repository;

  RegisterUseCase(this._repository);

  /// Execute the registration action.
  Future<({User user, AuthTokens tokens})> call({
    required String email,
    required String password,
    required String fullName,
  }) async {
    return await _repository.register(
      email: email,
      password: password,
      fullName: fullName,
    );
  }
}