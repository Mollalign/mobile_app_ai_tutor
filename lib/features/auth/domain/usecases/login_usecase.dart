import '../entities/entities.dart';
import '../repositories/repositories.dart';

/// Use case for user login.
/// 
/// Single responsibility: Authenticate user with email and password.
class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  /// Execute the login action.
  /// 
  /// Parameters:
  /// - [email]: User's email address
  /// - [password]: User's password
  /// 
  /// Returns: Record containing [User] and [AuthTokens]
  /// Throws: Exception on failure
  Future<({User user, AuthTokens tokens})> call({
    required String email,
    required String password,
  }) async {
    // You could add business logic here, like:
    // - Validate email format
    // - Check password length
    // - Log analytics events
    
    return await _repository.login(
      email: email,
      password: password,
    );
  }
}