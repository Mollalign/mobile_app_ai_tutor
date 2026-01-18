import '../entities/entities.dart';
import '../repositories/repositories.dart';

/// Use case for getting the current authenticated user.
class GetCurrentUserUseCase {
  final AuthRepository _repository;

  GetCurrentUserUseCase(this._repository);

  /// Get current user.
  /// 
  /// Returns [User] if authenticated, null otherwise.
  Future<User?> call() async {
    return await _repository.getCurrentUser();
  }
}