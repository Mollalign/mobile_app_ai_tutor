import '../repositories/repositories.dart';

/// Use case for checking authentication status.
/// 
/// Used at app startup to determine if user should see
/// login screen or dashboard.
class CheckAuthStatusUseCase {
  final AuthRepository _repository;

  CheckAuthStatusUseCase(this._repository);

  /// Check if user is authenticated.
  /// 
  /// Returns true if valid tokens exist.
  Future<bool> call() async {
    return await _repository.isAuthenticated();
  }
}