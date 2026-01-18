import 'package:dio/dio.dart';
import '../constants/constants.dart';
import '../errors/errors.dart';
import './interceptors/auth_interceptor.dart';
import 'package:flutter/foundation.dart';

/// Main HTTP client for API communication.
/// 
/// Singleton that provides a configured Dio instance with:
/// - Base URL configuration
/// - Timeout settings
/// - Auth interceptor for automatic token handling
/// - Error transformation
class ApiClient {
  // Singleton pattern
  ApiClient._internal();
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio _dio;
  late final AuthInterceptor _authInterceptor;
  bool _isInitialized = false;

  /// Initialize the API client. Must be called once before use.
  void init({void Function()? onLogout}) {
    if (_isInitialized) return;

    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.apiBaseUrl,
        connectTimeout: Duration(milliseconds: ApiConstants.connectionTimeout),
        receiveTimeout: Duration(milliseconds: ApiConstants.receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add logging interceptor in debug mode
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        logPrint: (obj) => debugPrint('📡 $obj'),
      ),
    );

    // Add auth interceptor
    _authInterceptor = AuthInterceptor(
      dio: _dio,
      onLogout: onLogout,
    );
    _dio.interceptors.add(_authInterceptor);

    _isInitialized = true;
  }

  /// Get the Dio instance (for direct usage if needed).
  Dio get dio {
    _ensureInitialized();
    return _dio;
  }

  /// Set the logout callback (can be updated after init).
  set onLogout(void Function()? callback) {
    _authInterceptor.onLogout = callback;
  }

  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError(
        'ApiClient not initialized. Call ApiClient().init() first.',
      );
    }
  }

  // ============================================================
  // HTTP Methods
  // ============================================================

  /// GET request.
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    _ensureInitialized();
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// POST request.
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    _ensureInitialized();
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT request.
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    _ensureInitialized();
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE request.
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    _ensureInitialized();
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================================
  // Error Handling
  // ============================================================

  /// Transform DioException into our custom exceptions.
  AppException _handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutException();

      case DioExceptionType.connectionError:
        return const NetworkException();

      case DioExceptionType.badResponse:
        return _handleResponseError(e.response);

      case DioExceptionType.cancel:
        return const ServerException('Request cancelled');

      default:
        return ServerException(e.message ?? 'Unknown error occurred');
    }
  }

  /// Handle HTTP response errors.
  AppException _handleResponseError(Response? response) {
    final statusCode = response?.statusCode;
    final data = response?.data;
    
    // Extract error message from response
    String message = 'Server error occurred';
    if (data is Map) {
      message = data['detail'] ?? data['message'] ?? message;
    }

    switch (statusCode) {
      case 400:
        return ServerException(message, 400);
      case 401:
        return UnauthorizedException(message);
      case 403:
        return ForbiddenException(message);
      case 404:
        return NotFoundException(message);
      case 422:
        final Map<String, dynamic>? validationData =
            data is Map ? (data).cast<String, dynamic>() : null;
        return ValidationException(message, validationData);
      case 500:
      case 502:
      case 503:
        return const ServerException('Server is temporarily unavailable');
      default:
        return ServerException(message, statusCode);
    }
  }
}