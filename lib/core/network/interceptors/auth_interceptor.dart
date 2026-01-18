import 'dart:async';
import 'package:dio/dio.dart';
import '../../constants/constants.dart';
import '../../storage/storage.dart';

/// Interceptor that handles authentication for all requests.
/// 
/// Responsibilities:
/// 1. Attach Bearer token to outgoing requests
/// 2. Handle 401 errors by refreshing token
/// 3. Retry failed requests after token refresh
/// 4. Trigger logout when refresh fails
class AuthInterceptor extends Interceptor {
  final Dio _dio;
  final SecureStorage _storage;
  
  // Callback to trigger logout (will be set by the app)
  void Function()? onLogout;
  
  // Flag to prevent multiple simultaneous refresh attempts
  bool _isRefreshing = false;
  
  // Queue of requests waiting for token refresh
  final List<({RequestOptions options, ErrorInterceptorHandler handler})> _pendingRequests = [];

  AuthInterceptor({
    required Dio dio,
    SecureStorage? storage,
    this.onLogout,
  })  : _dio = dio,
        _storage = storage ?? SecureStorage();

  // ============================================================
  // onRequest: Add Bearer token to outgoing requests
  // ============================================================
  
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth header for auth endpoints (login, register, refresh)
    if (_isAuthEndpoint(options.path)) {
      return handler.next(options);
    }

    // Get access token
    final accessToken = await _storage.getAccessToken();
    
    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    return handler.next(options);
  }

  // ============================================================
  // onError: Handle 401 errors
  // ============================================================
  
  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Only handle 401 Unauthorized
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    // Don't retry auth endpoints (prevents infinite loop)
    if (_isAuthEndpoint(err.requestOptions.path)) {
      return handler.next(err);
    }

    // If already refreshing, queue this request
    if (_isRefreshing) {
      _pendingRequests.add((options: err.requestOptions, handler: handler));
      return;
    }

    _isRefreshing = true;

    try {
      // Attempt to refresh the token
      final success = await _refreshToken();
      
      if (success) {
        // Retry the original request with new token
        final response = await _retryRequest(err.requestOptions);
        
        // Also retry all queued requests
        _retryPendingRequests();
        
        return handler.resolve(response);
      } else {
        // Refresh failed, logout user
        await _handleLogout();
        return handler.next(err);
      }
    } catch (e) {
      // Refresh threw error, logout user
      await _handleLogout();
      return handler.next(err);
    } finally {
      _isRefreshing = false;
    }
  }

  // ============================================================
  // Private Helper Methods
  // ============================================================

  /// Check if the path is an auth endpoint (doesn't need token).
  bool _isAuthEndpoint(String path) {
    final authPaths = [
      '/auth/login',
      '/auth/register',
      '/auth/refresh',
      '/auth/forgot-password',
      '/auth/verify-reset-code',
      '/auth/reset-password',
    ];
    
    return authPaths.any((authPath) => path.contains(authPath));
  }

  /// Attempt to refresh the access token.
  /// 
  /// Returns true if refresh was successful, false otherwise.
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _storage.getRefreshToken();
      
      if (refreshToken == null) {
        return false;
      }

      // Make refresh request (using a separate Dio instance to avoid interceptor loop)
      final response = await Dio().post(
        ApiConstants.refreshToken,
        data: {'refresh_token': refreshToken},
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        
        // Update stored tokens
        await _storage.updateAccessToken(
          accessToken: data['access_token'],
          expiresIn: data['expires_in'],
        );
        
        return true;
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Retry a request with the new token.
  Future<Response> _retryRequest(RequestOptions requestOptions) async {
    final accessToken = await _storage.getAccessToken();
    
    // Clone the request with new token
    final options = Options(
      method: requestOptions.method,
      headers: {
        ...requestOptions.headers,
        'Authorization': 'Bearer $accessToken',
      },
    );

    return _dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  /// Retry all pending requests after successful token refresh.
  void _retryPendingRequests() async {
    for (final pending in _pendingRequests) {
      try {
        final response = await _retryRequest(pending.options);
        pending.handler.resolve(response);
      } catch (e) {
        pending.handler.reject(
          DioException(requestOptions: pending.options, error: e),
        );
      }
    }
    _pendingRequests.clear();
  }

  /// Handle logout (clear storage and call callback).
  Future<void> _handleLogout() async {
    _pendingRequests.clear();
    await _storage.clearAll();
    onLogout?.call();
  }
}