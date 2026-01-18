import '../../../../core/network/network.dart';
import '../models/models.dart';

/// Remote data source for authentication API calls.
/// 
/// This class is responsible ONLY for:
/// - Making HTTP requests to the backend
/// - Parsing JSON responses into Models
/// 
/// It does NOT handle:
/// - Token storage (that's the repository's job)
/// - Error transformation (that's the repository's job)
/// - Business logic (that's the use case's job)
abstract class AuthRemoteDataSource {
  /// POST /auth/register
  Future<TokenModel> register({
    required String email,
    required String password,
    required String fullName,
  });

  /// POST /auth/login
  Future<TokenModel> login({
    required String email,
    required String password,
  });

  /// POST /auth/refresh
  Future<RefreshTokenModel> refreshToken(String refreshToken);

  /// GET /auth/me
  Future<UserModel> getCurrentUser();

  /// POST /auth/forgot-password
  Future<MessageResponseModel> requestPasswordReset(String email);

  /// POST /auth/verify-reset-code
  Future<MessageResponseModel> verifyResetCode({
    required String email,
    required String code,
  });

  /// POST /auth/reset-password
  Future<MessageResponseModel> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  });
}

/// Implementation of [AuthRemoteDataSource].
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSourceImpl({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  @override
  Future<TokenModel> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final response = await _apiClient.post(
      '/auth/register',
      data: {
        'email': email,
        'password': password,
        'full_name': fullName,
      },
    );

    return TokenModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<TokenModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      '/auth/login',
      data: {
        'email': email,
        'password': password,
      },
    );

    return TokenModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<RefreshTokenModel> refreshToken(String refreshToken) async {
    final response = await _apiClient.post(
      '/auth/refresh',
      data: {
        'refresh_token': refreshToken,
      },
    );

    return RefreshTokenModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<UserModel> getCurrentUser() async {
    final response = await _apiClient.get('/auth/me');

    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<MessageResponseModel> requestPasswordReset(String email) async {
    final response = await _apiClient.post(
      '/auth/forgot-password',
      data: {'email': email},
    );

    return MessageResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<MessageResponseModel> verifyResetCode({
    required String email,
    required String code,
  }) async {
    final response = await _apiClient.post(
      '/auth/verify-reset-code',
      data: {
        'email': email,
        'code': code,
      },
    );

    return MessageResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<MessageResponseModel> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    final response = await _apiClient.post(
      '/auth/reset-password',
      data: {
        'email': email,
        'code': code,
        'new_password': newPassword,
      },
    );

    return MessageResponseModel.fromJson(response.data as Map<String, dynamic>);
  }
}