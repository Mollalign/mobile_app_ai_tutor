import 'package:dio/dio.dart';

/// Simple in-memory GET cache with TTL.
///
/// Caches successful GET responses and serves them for subsequent
/// identical requests within the [maxAge] window.
/// Mutations (POST/PUT/DELETE/PATCH) automatically invalidate
/// cache entries whose URL prefix matches the mutation path.
class CacheInterceptor extends Interceptor {
  final Duration maxAge;
  final Map<String, _CacheEntry> _cache = {};

  CacheInterceptor({this.maxAge = const Duration(minutes: 5)});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (options.method.toUpperCase() != 'GET') {
      _invalidateRelated(options.uri.toString());
      handler.next(options);
      return;
    }

    final key = options.uri.toString();
    final entry = _cache[key];
    if (entry != null && !entry.isExpired) {
      handler.resolve(
        Response(
          requestOptions: options,
          data: entry.data,
          statusCode: 200,
          headers: entry.headers,
        ),
        true,
      );
      return;
    }

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.requestOptions.method.toUpperCase() == 'GET' &&
        response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      final key = response.requestOptions.uri.toString();
      _cache[key] = _CacheEntry(
        data: response.data,
        headers: response.headers,
        expiry: DateTime.now().add(maxAge),
      );
    }
    handler.next(response);
  }

  /// Remove cached entries whose key starts with a prefix derived from [url].
  /// e.g. POST /conversations/123/messages invalidates GET /conversations/123/*
  void _invalidateRelated(String url) {
    final basePath = Uri.parse(url).path;
    _cache.removeWhere((key, _) {
      final cachedPath = Uri.parse(key).path;
      return cachedPath.startsWith(basePath) || basePath.startsWith(cachedPath);
    });
  }

  void clear() => _cache.clear();
}

class _CacheEntry {
  final dynamic data;
  final Headers headers;
  final DateTime expiry;

  _CacheEntry({
    required this.data,
    required this.headers,
    required this.expiry,
  });

  bool get isExpired => DateTime.now().isAfter(expiry);
}
