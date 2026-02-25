import '../entities/entities.dart';
import '../repositories/repositories.dart';

/// Use case for Google Sign-In authentication.
class GoogleSignInUseCase {
  final AuthRepository _repository;

  GoogleSignInUseCase(this._repository);

  /// Execute the Google Sign-In flow.
  ///
  /// Launches the Google Sign-In SDK, obtains an ID token,
  /// sends it to the backend for verification, and returns
  /// the authenticated user with tokens.
  Future<({User user, AuthTokens tokens})> call() async {
    return await _repository.googleSignIn();
  }
}
