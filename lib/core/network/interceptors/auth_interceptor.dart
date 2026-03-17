import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../config/env.dart';

class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  bool _isRefreshing = false;
  final List<_PendingRequest> _pendingRequests = [];

  static const _publicPaths = [
    '/auth/login',
    '/auth/register',
    '/auth/refresh',
    '/auth/forgot-password',
    '/auth/reset-password',
  ];

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final isPublic = _publicPaths.any((p) => options.path.contains(p));
    if (!isPublic) {
      final token = await _storage.read(key: 'access_token');
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    // Don't retry refresh calls themselves
    if (err.requestOptions.path.contains('/auth/refresh')) {
      await _clearTokens();
      handler.next(err);
      return;
    }

    if (_isRefreshing) {
      // Queue this request until refresh completes
      _pendingRequests.add(_PendingRequest(err.requestOptions, handler));
      return;
    }

    _isRefreshing = true;

    try {
      final refreshToken = await _storage.read(key: 'refresh_token');
      if (refreshToken == null) {
        await _clearTokens();
        handler.next(err);
        return;
      }

      final refreshDio = Dio(BaseOptions(
        baseUrl: Env.apiBaseUrl,
        headers: {'Content-Type': 'application/json'},
      ));

      final refreshResponse = await refreshDio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      // Handle both snake_case and camelCase response keys
      final newAccessToken =
          refreshResponse.data['access_token'] ?? refreshResponse.data['accessToken'];
      final newRefreshToken =
          refreshResponse.data['refresh_token'] ?? refreshResponse.data['refreshToken'];

      if (newAccessToken == null) {
        await _clearTokens();
        handler.next(err);
        return;
      }

      await _storage.write(key: 'access_token', value: newAccessToken);
      if (newRefreshToken != null) {
        await _storage.write(key: 'refresh_token', value: newRefreshToken);
      }

      // Retry original request
      final retryResponse = await _retry(err.requestOptions, newAccessToken);
      handler.resolve(retryResponse);

      // Retry all queued requests
      for (final pending in _pendingRequests) {
        try {
          final response = await _retry(pending.options, newAccessToken);
          pending.handler.resolve(response);
        } catch (e) {
          pending.handler.next(err);
        }
      }
    } catch (_) {
      await _clearTokens();
      // Reject all pending requests
      for (final pending in _pendingRequests) {
        pending.handler.next(err);
      }
      handler.next(err);
    } finally {
      _pendingRequests.clear();
      _isRefreshing = false;
    }
  }

  Future<Response> _retry(RequestOptions options, String token) {
    final retryDio = Dio(BaseOptions(baseUrl: Env.apiBaseUrl));
    options.headers['Authorization'] = 'Bearer $token';
    return retryDio.fetch(options);
  }

  Future<void> _clearTokens() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
  }
}

class _PendingRequest {
  final RequestOptions options;
  final ErrorInterceptorHandler handler;
  _PendingRequest(this.options, this.handler);
}
