import '../repositories/repositories.dart';

/// Use case for user logout.
class LogoutUseCase {
  final AuthRepository _repository;

  LogoutUseCase(this._repository);

  /// Execute the logout action.
  /// 
  /// Clears all authentication data.
  Future<void> call() async {
    await _repository.logout();
  }
}